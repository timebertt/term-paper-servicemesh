# Service Mesh

A service mesh is another abstraction layer that builds right on top of the previously discussed abstractions. But, instead of abstracting specific hardware (Virtual Machines), abstracting the runtime environment (Containers) or a specific infrastructure (Kubernetes) it abstracts inter-service communication of microservices. It directly addresses the common challenges of service-to-service communication of a large fleet of microservices revealed previously.


## Basic Idea

- side-car proxy
- out-of process architecture
- all communication through side-car proxy

## Advantages

- language-agnostic
- decoupling services
- gradual/canary rollout
- inter-service communication is configured/managed centrally
- mutual Authentication
- (Inter-Cluster communication) [^multicluster]
- ecosystem / many community-supported tools and frameworks

[^multicluster]: [https://www.infoq.com/articles/kubernetes-multicluster-comms/](https://www.infoq.com/articles/kubernetes-multicluster-comms/)

## Popular Implementations

Kubernetes/VM based:

- Istio [@istiodocs]
- Linkerd
- Conduit
- Consul
- Kuma
- Traefik Maesh

On Cloud Provider / Platform:

- AWS App Mesh
- GCP Anthos Service Mesh / [Traffic Director](https://cloud.google.com/traffic-director/)

## Disadvantages

- added complexity, ooperational overhead
- compute overhead
