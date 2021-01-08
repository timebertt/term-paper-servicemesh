# Service Mesh

A service mesh is another abstraction layer that builds right on top of the previously discussed abstractions. But, instead of abstracting specific hardware (Virtual Machines), abstracting the runtime environment (Containers) or a specific infrastructure (Kubernetes) it abstracts inter-service communication of microservices. It directly addresses the common challenges in service-to-service communication of a large distributed and microservice-oriented systems discussed above.
Though, instead of adding another platform or deployment layer, the abstraction done in a service mesh integrates with microservices on the application layer in a side-by-side manner.

\todo[inline]{rewrite?}

## Basic Idea

The fundamental idea behind a service mesh is to move the responsibility for communication tasks out of individual services.
This is achieved using an out-of-process architecture in the form of introducing a so called "sidecar proxy" [@bryant2020servicemesh]. This is an application layer (layer 7) network proxy running right next to every single service instance. It transparently routes all network traffic a single instance receives (ingress) and sends (egress).
This means, it is acting as a front proxy for the service instance accepting incoming traffic. On the other hand, it is also acting as a traditional proxy routing traffic to other application services and to the outside world. When communicating with other services, the traffic is routed to the proxy sitting in front of the other service again. This way, the sidecar proxies form a meshed network between microservices – a service mesh.

![Service Mesh schematic [@redhatservicemesh]](../assets/service-mesh-scheme.png)

With this architecture, the service proxy is on the critical path for all application traffic, allowing to route, shape, secure, trace, monitor and load balance all traffic in a consistent manner completely independently from individual service implementations.

## Architecture

A service mesh is typically composed of two parts: the data plane and the control plane.
In short, the **data plane** most prominently consists of the service proxy, which routes, secures and observes networking traffic between different service instances. It "touches every packet/request in the system [and is] responsible for service discovery, health checking, routing, load balancing, authentication/authorization, and observability".
The **control plane** on the other hand is responsible for policy and configuration management of the service proxies running in the data plane. It doesn't touch any actual application traffic and only configures service proxies according to the user's given intent [@klein2017servicemeshplanes].

Conceptually, implementations of both planes may be interchangeable, meaning the same data plane (service proxy) can be used by different control plane implementations, and control plane implementations might support using different data planes.

![Service Mesh Architecture [@nginx2018servicemesh]](../assets/service-mesh-arch.png)

### The Data Plane

A service mesh's data plane is charged with the following tasks:

**Service discovery**: In order to communicate with other services, the service proxy has to discover where instances of the desired services are running and which of them it should connect to, e.g. based on the geographical placement and network latency. This typically involves leveraging some sort of lookup mechanism like DNS name resolution or talking to the container orchestration API to find available endpoints of a service.

**Health checking**: Once the service proxy has discovered available endpoints of other services, it often performs additional health checking measures, in order to route traffic only to healthy service instances. This may include active health checks, i.e. out-of-band API calls to dedicated health endpoints of peer services. Additionally, proxies may perform passive health checking, e.g. in the form of outlier detection. This means, using quality of service metrics like request success rate or request latency of active connections as indicators of upstream healthiness [@envoydocs].

**Traffic management**: This is probably the most comprehensive task of the data plane and often consists of a lot of different aspects:

- routing based on the used protocol, e.g. HTTP path, query or header based routing (layer 7 routing)
- routing based on metadata information, e.g. zone-aware routing
- load balancing across upstream endpoints according to different configured algorithms like weighted round robin, ring hash or random load balancing
- percentage or hash based traffic splitting and shifting between multiple upstream endpoints
- traffic manipulation, e.g. host and prefix rewriting or redirects
- circuit breaking and applying back pressure during local load spikes
- applying timeouts to upstream requests
- automatic retries on upstream failure responses
- global and distributed rate limiting
- upstream connection pooling
- automatic traffic compression

The options for traffic management in the data plane are manifold and heavily depend on what the used service proxy offers.

**Encryption**: The data plane is often configured to provide TLS encrypted communication between different service instances. This relieves developers from the responsibility to properly secure their services and to implement the required security standards. As encryption is a security-sensitive concern, managing it centrally and consistently across the whole data plane decreases the number of an application's external dependencies, that may include critical vulnerabilities. Thereby the application's attack surface can be reduced to a minimum.

**Authentication and authorization**: Many data plane implementations provide different mechanisms for authenticating clients and other service proxies. This is often achieved in the form of mutual TLS authentication using public key infrastructure (PKI), which hands out client certificates to all service proxies, that are signed and can be verified by an application-wide certificate authority (CA).
Additionally, service proxies may implement additional mechanisms for authorizing clients and other services to access only a given subset of a service's API endpoints and enforce other similar restrictions for securing inter-service communication.

**Observability**: Another task of the data plane is to collect metrics and traces and output logs for each request to offer insights into the distributed traffic flow of a microservice-oriented application. On the one hand, this can help development and operations teams to understand, analyze and detect outages, performance degradation and other problems. On the other hand, the collected metrics regarding service performance, load and instance utilizations can be used to trigger automated operation decisions like automatic scaling of services or alerting an operations team as soon as a problematic behavior occurs.

**Ingress / API Gateway**: While the main concern of the data plane is to manage inter-service communication – called east-west traffic – some data plane implementations also offer support for running the service proxy as an API Gateway that manages ingress traffic from outside the application – called north-south traffic. Although this is not strictly required from a data plane implementation, running the same service proxy also at the edge of the application brings a number of advantages. For example, the exact same mechanisms for controlling, securing and observing traffic can be applied to the application's ingress traffic in a consistent manner. This brings the same configuration options and experience also to the entry point of an application.

### The Control Plane

The control plane of a service mesh supervises all work of the data plane. That is, it takes over the following responsibilities:

**Central configuration management**: First of all, the control plane is responsible for offering means to manage the data plane's configuration. That means, some form of mechanism for specifying the desired behavior of the service proxies running in the data plane. Mostly, this mechanism is provided by exposing a configuration API or integration into an existing but extensible API. For example [Istio](#sec:implementations) leverages [Kubernetes' built-in extension points](#k8s:extensibility) (more specifically `CustomResourceDefinitions`) for extending the Kubernetes API and thereby making it possible to uniformly manage workload and service mesh configuration via the same established mechanisms and tools.
Furthermore, some service mesh implementations come with administration UIs or third party UI addons exist, which allow even easier configuration management in addition to programmatic API access [@linkerddocs].

**Managing service proxies**: Another crucial task of the control plane is to manage configuration and lifecycle of the service proxies that are actually forming the service mesh. The first step of this task is to deploy the sidecar proxy to every microservice instance. This can either be handled manually by the user with the help of some provided tools. But more often it is achieved via some form of automation for hooking into the workload's lifecycle itself. For example [Istio and \mbox{Linkerd}](#sec:implementations) can be configured to also use [Kubernetes' extension mechanisms](#k8s:extensibility) for injecting the sidecar proxy into Pod manifests of service instances. In this case, `MutatingWebhookConfigurations` are utilized to alter Pod specifications during their admission phase and add an additional container running the service proxy. As all containers in a Pod share the same Linux network namespace, they can communicate via `localhost`, which provides a simple mechanism for the proxy-to-service communication ([@sec:kubernetes]).

The next step is to apply the user-given configuration for the behavior of the data plane to the service proxies. This includes configuration for all the aforementioned features like health checking, load balancing, circuit breaking and so on. Some service proxies offer a management API for this purpose, others support hot reload of their configuration files. The last part of this task is providing the needed service discovery information in a format that the proxies are able to deal with. This typically involves requesting, transforming and exposing information from a central service registry or the orchestration platform's API.

**Trust management**: Another task of the control plane is to handle certificate management and other security-related requirements. This usually includes an application-wide PKI and CA, which is used to sign and verify service-specific TLS certificates. The control plane provides mechanisms to automatically generate, distribute and rotate service certificates, e.g. when new services are deployed. By this, mutual TLS authentication between service instances can be utilized and trust is established in inter-service communication. Additionally, the control plane provides means to distribute authentication and authorization settings across all service proxies and thus enforcing policies for inter-service communication.

**Aggregating telemetry data**: More over, the control plane takes care of aggregating and exposing the metrics and traces collected by the data plane in a human-consumable way. In most implementations, other well-known open-source projects such as Prometheus, Grafana, Jaeger, Zipkin and Kiali are leveraged to make telemetry data accessible using some form of query-language and visualization in well-arranged dashboards [@istiodocs]. This allows development and operations teams to get deep analytical insights into service performance and the behavior of distributed request chains.

## Popular Implementations {#sec:implementations}

Over the past few years, a lot of excitement about service mesh technology has built up in the cloud-native community. This has fostered development of numerous service mesh implementations, both open-source and proprietary ones.
Some implementations reuse already existing and well-established service proxies for the data plane (e.g. NGINX), other use newer technologies (e.g. Envoy, traefik) and others implement an own proxy (e.g. linkerd-proxy).

Some of the most popular service mesh implementations are the following: [^servicemeshlandscape]

- Istio [@istiodocs]
- Linkerd [@linkerddocs]
- Consul Connect
- Kuma
- Traefik Maesh
- Open Service Mesh
- NGINX Service Mesh
- AWS App Mesh
- GCP Anthos Service Mesh
- Azure Service Fabric Mesh

[^servicemeshlandscape]: See [https://servicemesh.es/](https://servicemesh.es/) for a more extensive and detailed list of available service mesh implementations.

Most of the mentioned implementations are either entirely Kubernetes-based or support Kubernetes as one of their platform choices. The reason for this is that Kubernetes features [well-defined mechanisms for extending its API and workload lifecycle](#k8s:extensibility). This allows tools to offer first-class integration with the Kubernetes API and users to manage the service mesh itself alongside the actual workload. This makes it easy for teams to implement and operate a service mesh in their microservice-oriented applications. Furthermore, the whole ecosystem and community around the Kubernetes open-source project has grown immensely, meaning there are countless tools, frameworks and projects for distributed tracing, observability, security and other cross-cutting concerns, that integrate well with Kubernetes.

## Advantages

Large microservice-oriented applications tend to be difficult to develop and operate at scale. One of the biggest challenges, application teams will face, is to implement dynamic, efficient, secure and observable networking in such a distributed system with many services. Service-to-service communication is what powers microservices and actually brings value to them [@redhatservicemesh].
As this communication touches all application services, it is a cross-cutting concern. With this, it shouldn't be needed to implement those requirements repeatedly in every service or programming language and not even in every application.
By using service mesh, these cross-cutting concerns of inter-service communication can be abstracted and thereby extracted out of application and service code. A service mesh seamlessly integrates into the application layer and makes the underlying network transparent.
And by abstracting all these cross-cutting concerns, a service mesh brings back the developers' focus to their service's business logic.

As a service mesh uses an out-of-process architecture, it can be leveraged by applications written in every programming language and in any number of different programming languages. The only requirement is the use of standard protocols like TCP, HTTP, TLS and so on, which most applications which involve inter-service communication already do [@envoydocs]. Another advantage is, that with a service mesh all service-to-service communication can be centrally and consistently designed, configured and managed via an API as opposed to distributed and service-specific configuration files or APIs.

Furthermore, a service mesh can provide increased reliability of inter-service communication and prohibit cascading failures in a distributed system [@lyftcasestudy]. By leveraging automatic retries, outlier detection and different service discovery mechanisms, services are protected against peer unhealthiness and can automatically perform failover measures. Also, with the possibility to centrally manage identity, authentication and authorization of service proxies, the security of inter-service communication can be increased, while the attack surface for vulnerabilities is decreased.

Additionally, with a service mesh novel approaches for rolling out single services of an application in a graceful manner can be taken and implemented. Traffic can be shaped and gradually shifted from one location to another or split between multiple versions according to different policies. During this, service performance and quality can be monitored in harmonized and well-arranged dashboards [@bryant2020servicemesh].

Although service meshes will unroll their full potential and value when utilized in large-scale deployments of microservices, they can also support the migration of already existing application, that were developed in a monolithic style, to a microservices-oriented style, by connecting legacy applications with factored-out services. In the same way, they also support co-located or hybrid deployment scenarios, e.g. with parts of an application deployed in the public cloud, while another part is running in a private cloud environment. For some use cases, like geographically distributed applications, some service mesh implementations also provide multi-cluster setups, where microservices running on different Kubernetes clusters are connected to one single, logical service mesh [@istiodocs] [@jenkins2019multicluster].

Last but not least, another advantage of using a service mesh is the very active community around this topic and cloud-native technology in general. Thus, there are quite a lot of community-supported tools and open-source projects, that application teams can profit from.

## Disadvantages

- added complexity, steeper learning curve, operational overhead
- compute overhead
- latency overhead, two additional hops (over localhost in kubernetes)
- implementation lock-in / lack of portability between service meshes / proxies

## Future work

- userspace networking (ref cillium, eBPF) to reduce network overhead and latency
- cillium: proxy sharing between services to reduce compute overhead
- Service Mesh Interface for standardization of Control Plane API and portability
- Universal data plane API for standardization of Data Plane API and pluggable service proxies
