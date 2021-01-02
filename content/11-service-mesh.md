# Service Mesh

## Basic Idea

- side-car proxy (language-agnostic)
- all communication through side-car proxy

## Advantages

- decoupling services
- gradual/canary rollout
- inter-service communication is configured/managed centrally

## Examples

On Kubernetes:

- Istio [@istiodocs]
- Linkerd
