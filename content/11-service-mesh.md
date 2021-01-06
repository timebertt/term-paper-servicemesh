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

A service mesh is typically composed of two parts: the data plane and the control plane [@klein2017servicemeshplanes].
In short, the **data plane** most prominently consists of the service proxy, which routes, secures and observes networking traffic between different service instances. It "touches every packet/request in the system [and is] responsible for service discovery, health checking, routing, load balancing, authentication/authorization, and observability".
The **control plane** on the other hand is responsible for policy and configuration management of the service proxies running in the data plane. It doesn't touch any actual application traffic and only configures service proxies according to the user's given intent.

Conceptually, implementations of both planes may be interchangeable, meaning the same data plane (service proxy) can be used by different control plane implementations, and control plane implementations might support using different data planes.

![Service Mesh Architecture [@nginx2018servicemesh]](../assets/service-mesh-arch.png)

### The Data Plane

A service mesh's data plane is charged with the following tasks:

**Service discovery**: In order to communicate with other services, the service proxy has to discover where instances of the desired services are running and which of them it should connect to, e.g. based on the geographical placement and network latency. This typically involves leveraging some sort of lookup mechanism like DNS name resolution or talking to the container orchestration API to find available endpoints of a service.

**Health checking**: Once the service proxy has discovered available endpoints of other services, it often performs additional health checking measures, in order to route traffic only to healthy service instances. This may include active health checks, i.e. out-of-band API calls to dedicated health endpoints of other services. Additionally, proxies may perform passive health checking, e.g. in the form of outlier detection. This means, using quality of service metrics like request success rate or request latency of active connections as indicators of upstream healthiness [@envoydocs].

**Traffic routing**:

- load balancing
- traffic shaping
- circuit breaking
- timeouts
- retries
- rate limiting

**Load Balancing**:

**Authentication and authorization**:

**Observability**:

**Ingress/Edge proxy**:

### The Control Plane

- central configuration API
- configuring service proxies
- making telemetry data accessible (visualization/UIs?dashboards/...)

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
- inter-service communication is configured/managed centrally
- mutual Authentication
- (Inter-Cluster communication) [^multicluster]
- ecosystem / many community-supported tools and frameworks

[^multicluster]: [https://www.infoq.com/articles/kubernetes-multicluster-comms/](https://www.infoq.com/articles/kubernetes-multicluster-comms/)

## Disadvantages

- added complexity, ooperational overhead
- compute overhead
