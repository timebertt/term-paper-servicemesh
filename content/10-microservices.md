# Microservices

## What are Microservices?

- Differentiation to Service-Oriented-Architecture
  - mainly Microservices is SOA but defined more precisely and crisply
- automated deployment machinery

The microservice architectural style [@fowler2014microservices] has been the go-to architecture for building modern large-scale applications for a couple of years now.
In comparison to traditional monolithic applications, microservice-oriented applications are composed of a suite of small service units, each running in its own process, instead of a large executable running in a single process.
Every service provides a single aspect of the application's business logic and can communicate with other services via lightweight protocols such as HTTP(S).
Now, that the application's business logic is decomposed into small packages, each service can be developed, tested, released and deployed individually and independently of other components of the software.
This allows services to be developed in different programming languages, by different teams, to use their own suitable data management solution and to be deployed on completely different runtime stacks.
The only required common denominator of the different services are the protocols and APIs for communication.

## Motivation

The motivation for developing and refactoring applications in a microservices-oriented architecture comes from the downsides of traditionally developed monolithic software systems.
When changing a given component of such an application or adding a single feature, the whole application has to be built, tested and deployed.
Oftentimes, it's even quite difficult to run an instance of such applications on a development machine.
Additionally, all components of monoliths have to be written in the same programming language and are thus tied to the same compiler and library versions and have to be deployed on the same runtime stack.
All of these factors tend to foster high coupling of software components and slow down development and innovation speed as well as release and deployment frequency.
Lastly, the options of scaling a monolithic application are limited to deploying multiple instances of the whole application and balancing load across them as soon as demand for some components increases.

As the size of the product grows with increasing demand for new features and higher usage, it gets complicated to scale further in the means of people, features and application usage.
A microservices-oriented architecture can help address these challenges by decomposing applications into small services.

\todo[inline]{microservices allow the following / have these characteristics:}

- individual development and deployment of each service
- using different programming languages
- individual scaling of services
- DevOps culture (teams operate their own services)

## Containerization

Containers (operating system level virtualization) have grown in popularity over the past decade, also because it's a great fit for building microservice-oriented applications [@amaral2015performance].

Conceptually, containers are quite similar to traditional hypervisor based virtualization (virtual machines) in the way that they provide virtualized and isolated environment for applications and their components.
Virtual machines on one hand perform full virtualization of a given hardware and provide an own operating system, i.e. kernel, to each machine, which can be used to abstract software from specific hardware.
Containers on the other hand – e.g. in their most popular implementation by Docker [^docker] - are a based on isolation features of the Linux kernel like namespaces and cgroups [@merkel2014docker].
This means, that containers don't virtualize any hardware and don't run their own operating system, instead all containers running on one host machine share the same kernel.
Thus, containers are much more lightweight, faster in startup and more efficient than traditional virtual machines.

Additionally, container virtualization provides mechanisms to conveniently package, version and ship software in container images, which can be published to and retrieved from image registries.
When building application container images, typically a base image is selected and afterwards the component's executable, additional libraries and dependencies are added to the image, each resulting in a new image layer.
By that, a given application component is always bundled with all of its needed runtime dependencies, providing a well-defined runtime environment and self-contained executable package.
Though, because of the layered nature of container images, common base images and runtime versions can be cached and reused.

In order to run a given containerized application, only a compatible container runtime and access to the container registry is needed.
Before startup, the container image or missing layers thereof are pulled from the registry.
Afterwards a new container can be created from that image and started in a matter of seconds.

All of these advantages and mechanisms make containers a great fit for building microservice-oriented applications.
Every service of an application can be packaged in container images with its individual runtime dependencies and deployed independently from other services by just starting containers from that image.

why containerization helps in realizing a microservices architecture

- components packaged in self-contained units
- runtime dependencies
- isolation

[^docker]: [https://www.docker.com/](https://www.docker.com/)

## Kubernetes

which problem kubernetes solves for realizing a microservices architecture

- resources / infrastructure management (compute, storage, networking)
- scheduling
- service discovery

extensibility of k8s allows service mesh implementations like istio, linkerd

## Challenges

- remote calls are more expensive than in-process calls
- different programming languages
- traffic management
- security
- observability
