# Microservices

## Definition

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

## Containerizing Microservices

Containers (operating system level virtualization) have grown in popularity over the past decade, also because it's a great fit for building microservice-oriented applications [@amaral2015performance].

Conceptually, containers are quite similar to traditional hypervisor based virtualization (virtual machines) in the way that they provide virtualized and isolated environment for applications and their components.
Virtual machines on one hand perform full virtualization of a given hardware and provide an own operating system, i.e. kernel, to each machine, which can be used to abstract software from specific hardware.
Containers on the other hand – e.g. in their well-known implementation by Docker [^docker] - are a based on isolation features of the Linux kernel like namespaces and cgroups [@merkel2014docker].
This means, that containers don't virtualize any hardware and don't run their own operating system, instead all containers running on one host machine share the same kernel.
Thus, containers are much more lightweight, faster in startup and more efficient than traditional virtual machines.
And because of this, a single server or worker machine may easily host as many as 100 containers at the same time, allowing to achieve high resource utilization by sharing a host's compute resources between diverse workloads.

Additionally, container virtualization provides mechanisms to conveniently package, version and ship software in container images, which can be published to and retrieved from image registries.
When building application container images, typically a base image is selected and afterwards the component's executable, additional libraries and dependencies are added to the image, each resulting in a new image layer.
By that, a given application component is always bundled with all of its needed runtime dependencies, providing a well-defined runtime environment and self-contained executable package.
Though, because of the layered nature of container images, common base images and runtime versions can be cached and reused.

The process of running a containerized application is very simple and only requires a compatible container runtime and access to the container registry.
Before container can be started, the respective container image or missing layers thereof are pulled from the registry.
Afterwards a new container can be created from the image and started immediately. The application might take a few seconds to initialize. Though, the process of starting a new container from a present image is very fast, especially compared to starting up a new virtual machine.

All of these advantages and mechanisms make containers a great fit for building microservice-oriented applications.
Every service of an application can be packaged in container images with its individual runtime dependencies and brought up independently from other services just by starting containers from that image.
For example, if there are two services written in PHP and one of them is still depending on version 5 while the other one is requiring new features of version 7, this can be easily achieved by packaging and deploying them as individual containers as opposed to starting up different virtual machines satisfying the different runtime requirements.
The same applies, if development teams want to use a different set of libraries or even a completely different programming language.

Because containers are so lightweight and can be started up so quickly, it is also very easy to scale individual containerized services by just starting new instances of the same image and thereby increasing the amount of compute resources a single service can use.
By this, containerized microservices can be scaled in a fine-grained manner in comparison to monolithic applications, because the amount of load an individual component can handle, can now be increased simply by starting new containers of that service, while a monolithic application can only increase the capacity of its components in an equal manner.

\todo[inline]{isolation?}

[^docker]: [https://www.docker.com/](https://www.docker.com/)

## Kubernetes as a Deployment underlay

Once an application is split into a suite of microservices and packaged as a set of container images, it needs some infrastructure and platform to be run the containers on.
Even though, containerization provides a number of advantages for building microservice-oriented applications, as discussed above, it doesn't solve the problem of running, managing and connecting a fleet of containerized services.
That's where container orchestrators comes into play.

One popular open-source solution for managing high amounts of containers across large clusters of machines is Kubernetes [@k8sio].
Though, there are alternative container orchestration solutions, like Docker Swarm, Marathon/Mesos, HashiCorp Nomad, Amazon EC2 Container Service and Azure Container Service, Kubernetes has become the industry's de-facto standard for deploying, managing and scaling containerized applications.

Using Kubernetes as a container orchestration platform for running microservice-oriented applications brings a number of advantages:

**Resource Management**: Firstly, Kubernetes allows to efficiently manage compute resources used by different service instances. Each container can specify how many compute resources it needs to run properly and the Kubernetes scheduler will find a suitable node in the cluster for running the workload, that has enough free capacity. By this, Kubernetes allows to achieve high resource utilization across all used machines and thereby cutting down cost.

**High-Availability**: One of Kubernetes' core principles is high-availability and self-healing. This is achieved by implementing control plane components as controllers, which observe the current state of the workload and take actions to reach the specified desired state. E.g. Kubernetes offers to define application-specific health-checks, which allows to detecting and restarting unhealthy service instances.

**Auto-Scaling**:

- built-in auto-scaling capabilities

**Service Discovery**:

- service discovery

**Automated Rollouts**:

- automated rollout

**Container Networking**:

- network policies

**Uniform API**:

- uniform API for workload and configuration management

**Infrastructure Abstraction Layer**:

Finally, Kubernetes acts as an abstraction layer across a lot of infrastructures where one can deploy containerized workload, which makes containerized applications portable.
Not only is Kubernetes available as a managed service on many popular cloud platforms, there are also solutions for running it in a private cloud environment and also on a development machine.
Across all these different infrastructures Kubernetes abstracts management of example of compute, storage and network resources.

\todo[inline]{extensibility of k8s allows service mesh implementations like istio, linkerd}

## Challenges

- remote calls are more expensive than in-process calls
- different programming languages
- traffic management
- security
- observability
