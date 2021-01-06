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

**Authentication and authorization**: Many data plane implementations provide different mechanisms for authenticating clients and other service proxies. This is often achieved in the form of mutual TLS authentication using public key infrastructure, which hands out client certificates to all service proxies, that are signed and can be verified by an application-wide certificate authority.
Additionally, service proxies may implement additional mechanisms for authorizing clients and other services to access only a given subset of a service's API endpoints and enforce other similar restrictions for securing inter-service communication.

**Observability**: Another task of the data plane is to collect metrics and traces and output logs for each request to offer insights into the distributed traffic flow of a microservice-oriented application. On the one hand, this can help development and operations teams to understand, analyze and detect outages, performance degradation and other problems. On the other hand, the collected metrics regarding service performance, load and instance utilizations can be used to trigger automated operation decisions like automatic scaling of services or alerting an operations team as soon as a problematic behavior occurs.

**Ingress / API Gateway**: While the main concern of the data plane is to manage inter-service communication – called east-west traffic – some data plane implementations also offer support for running the service proxy as an API Gateway that manages ingress traffic from outside the application – called north-south traffic. Although this is not strictly required from a data plane implementation, running the same service proxy also at the edge of the application brings a number of advantages. For example, the exact same mechanisms for controlling, securing and observing traffic can be applied to the application's ingress traffic in a consistent manner. This brings the same configuration options and experience also to the entry point of an application.

### The Control Plane

- central configuration API
- configuring service proxies (optionally injecting it into workload)
- making telemetry data accessible (visualization/UIs/dashboards/...)

## Popular Implementations

Kubernetes/VM based:

- Istio [@istiodocs]
- Linkerd
- Conduit
- Consul
- Kuma
- Traefik Maesh
- NGINX Service Mesh

On Cloud Provider / Platform:

- AWS App Mesh
- GCP Anthos Service Mesh / [Traffic Director](https://cloud.google.com/traffic-director/)

## Advantages

- language-agnostic
- decoupling services
- gradual/canary rollout
- inter-service communication is configured / managed centrally
- mutual Authentication
- (Inter-Cluster communication) [^multicluster]
- ecosystem / many community-supported tools and frameworks

[^multicluster]: [https://www.infoq.com/articles/kubernetes-multicluster-comms/](https://www.infoq.com/articles/kubernetes-multicluster-comms/)

## Disadvantages

- added complexity, ooperational overhead
- compute overhead
