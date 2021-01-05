# Service Mesh

## Basic Idea

- side-car proxy
- all communication through side-car proxy

## Advantages

- language-agnostic
- decoupling services
- gradual/canary rollout
- inter-service communication is configured/managed centrally
- mutual Authentication
- (Inter-Cluster communication) [^multicluster]
- many community-supported tools and frameworks

[^multicluster]: [https://www.infoq.com/articles/kubernetes-multicluster-comms/](https://www.infoq.com/articles/kubernetes-multicluster-comms/)

## Implementations

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
