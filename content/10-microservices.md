# Microservices

## Definition

What are Microservices?

- go over literature
  - Fowler [@fowler2014microservices]
- Differentiation to Service-Oriented-Architecture

## Motivation

- Monolithic software systems
- challenges
  - scalability (technical as well as team)
  - common language/stack
  - innovation speed
  - continuous deployment/delivery
  - high coupling

microservices allow:

- individual development and deployment of each service
- using different programming languages
- individual scaling of services
- DevOps culture (teams operate their own services)

## Challenges

- different programming languages
- traffic management
- security
- observability

## Containerization

why containerization helps in realizing a microservices architecture

- components packaged in self-contained units
- runtime dependencies
- isolation

## Kubernetes

which problem kubernetes solves for realizing a microservices architecture

- resources / infrastructure management (compute, storage, networking)
- scheduling
- service discovery

extensibility of k8s allows service mesh implementations like istio, linkerd
