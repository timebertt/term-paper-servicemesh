# Microservices

## Introduction

The microservice architectural style [@fowler2014microservices] is a comparably new paradigm, but has been the go-to architecture for building modern large-scale applications for a couple of years now.
In comparison to traditional monolithic applications, microservice-oriented applications are composed of a suite of small service units, each running in their own process, instead of a large executable running in a single process.
Every service provides only a single aspect of the application's business logic and communicates with other services via lightweight protocols such as HTTP(S).
By splitting up the application's business logic into small packages, each service can be developed, tested, released, deployed and scaled individually and independently of other services.
This allows services to be developed in different programming languages, by different teams, to use an individual data management solution and to be deployed on completely different runtime stacks.
The only required agreement of different services are the protocols and APIs used for communication.

## Motivation

![Monoliths vs. Microservices [@fowler2014microservices]](../assets/scale-microservices.png)

The motivation for developing and transforming applications according to the microservices architectural style is rooted in the downsides of traditionally developed monolithic software systems.
When changing a given component of such an application or adding a new feature, the whole application has to be built, tested and deployed.
Oftentimes, it's quite difficult to run an instance of such applications on a development machine, so it becomes tedious and cumbersome to develop with prolonged turnaround times.
Additionally, all components of monoliths have to be written in the same programming language and are tied to the same compiler and library versions and have to be deployed on the same runtime stack.
All of these factors tend to foster high coupling of software components and slow down development and innovation speed as well as decrease release and deployment frequency.

Also, the options for scaling out a monolithic application are limited to deploying multiple instances of the whole application and balancing load across them as soon as demand for some components increases.
As the size of the product grows with increasing demand for new features and higher usage, it gets more complicated to scale further by means of team size, new features and application usage.
A microservices-oriented architecture can help address these challenges by decomposing applications into small service units.

## Characteristics

Although there is no formal definition for this architectural style, the most prominent and common characteristics of microservice-oriented architectures are the following: [@fowler2014microservices]

**Componentization via Services**: Splitting up systems into components, that are independently replaceable and upgradeable, and plugging them together to form a full application is very common in the software industry. Microservices are also based on componentization and their components are the individual services. Though, the key factor for microservices is that their components are services running in their own processes and are plugged together by communicating over standard network protocols or remote procedure calls. This is different to componentization via libraries or modules, where components are linked together into a single executable and communicate via in-memory function calls. This difference allows microservices to be arbitrarily distributed between machines, making it a distributed system.

**Organized in service teams**: When organizations build microservices-oriented applications, their teams are typically organized in service teams. These teams are focused on business capabilities of a small set of services rather than having teams focusing on different technical capabilities like for example UI and database specialists. This fosters strong collaboration between different areas of expertise inside the service teams. Also organization's communication structure maps to the inter-service communication of the developed services (Conway's law). Additionally, oftentimes development teams are simultaneously responsible for operating their services in production as well, which exposes them to real-world behavior of their services. This culture is often called "DevOps".

**Smart endpoints and dumb pipes**: In a microservice-oriented application the communication structures between different services neither perform any smart transformations nor apply business rules, in contrast to other systems like for example Enterprise Service Bus products. Processes only communicate via simple and lightweight protocols and the smarts live in the endpoints (services) themselves. This promotes low coupling and high cohesion of different services.

**Decentralized Governance**: Decentralizing governance over service implementation allows development teams to use the right tool for the job every time. When building new services they can choose a suitable programming language, framework and data management solution for each one of them individually and independently of other components. Especially, when development teams are also responsible for operating their services in production, governance is highly decentralized as opposed to having a dedicated operations team and centralized development governance over a monolithic application.

**Decentralized Data Management**: Microservices don't share a single database with all components of an application and rather have individual databases specific to each service (also called "Polyglot Persistence"). As mentioned, this allows to make database management solution decisions individually for each service. But this also implies that responsibility for data is shared across microservices, meaning that each service is managing only data and attributes specific to the service's business logic and relationship with other services data model are well-defined – similar to "Bounded Contexts" in Domain Driven Design.
This makes it hard to achieve strong consistency across all data and forces microservices to deal with eventual consistency of data.

**Infrastructure Automation**: The complexity of complete application deployments increases with use of the microservices style and it becomes generally more desireable to frequently deploy new versions of services independently from others. Thus, it's key to leverage automation systems for building, testing and deploying microservice-oriented applications. Code changes can be pushed through comprehensive pipelines featuring extensive automated tests and eventually automated deployment.

**Design for failure**: Individual services can fail at any time, for example caused by bugs, network failure or outages in the underlying infrastructure. Thus, it's crucial to design services to be able to handle failure of peer services gracefully. Additionally, such failures have to be detected early on. Therefore, real-time monitoring of the application is needed including for example details on availability, throughput, latency and even business relevant metrics.
As it's important to ensure that a system can keep operating even when failures occur, it is helpful to artificially introduce problems that might arise in normal operation. This approach is often referred to as Chaos Engineering and was originally introduced by Netflix [@chaosengineering]. With this, organizations are able to detect weaknesses of their services and sensitivity to failures in order to fix them early on in the development process.

## Containerizing Microservices

Containers (operating system level virtualization) have grown in popularity over the past decade, also because it's a great fit for building microservice-oriented applications [@amaral2015performance].

Conceptually, containers are quite similar to traditional hypervisor based virtualization (virtual machines) in the way that they provide virtualized and isolated environment for applications and their components.
Virtual machines on one hand often perform full virtualization of a given hardware and provide an own operating system, i.e. kernel, to each machine, which can be used to abstract software from specific hardware.
Containers on the other hand – e.g. in their well-known implementation by Docker [@dockercom] - are based on isolation features of the Linux kernel like namespaces and cgroups [@merkel2014docker].
This means, that containers don't virtualize any hardware and don't run their own operating system, instead all containers running on one host machine share the same kernel.
Thus, containers are much more lightweight on resources, faster in startup and more efficient than traditional virtual machines. Because of this, a single server or worker machine may easily host as many as 100 containers at the same time, allowing to achieve high resource utilization by sharing a host's compute resources between diverse workloads.

![Containers vs. VMs [@dockercom]](../assets/containers-vs-vms.png)

Additionally, container virtualization provides mechanisms to conveniently package, version and ship software in container images, which can be published to and retrieved from image registries.
When building application container images, typically a base image is selected and afterwards the component's executable, additional libraries and dependencies are added to the image, each resulting in a new image layer.
By that, a given application component is always bundled with all of its needed runtime dependencies, providing a well-defined runtime environment and self-contained executable package.
Because of the layered nature of container images, common base images and runtime versions can be cached and reused.

The process of running a containerized application is very simple and only requires a compatible container runtime and access to the container registry.
Before a new container is started, the respective container image or missing layers thereof are pulled from the registry.
Afterwards a new container can be created from the image and started immediately. The application might take a few seconds to initialize. Though, the process of starting a new container from an image, that is already present on the host machine is very fast, especially compared to starting up a new virtual machine.

All of these advantages and mechanisms make containers a great fit for building microservice-oriented applications.
With it, every service of an application can be packaged in container images with its individual runtime dependencies and brought up independently from other services just by starting containers from that image.
For example, if there are two services written in PHP and one of them is still depending on version 5 while the other one is requiring new features of version 7, this can be easily achieved by packaging and deploying them as individual containers as opposed to starting up different virtual machines satisfying the different runtime requirements.
The same applies, if development teams want to use a different set of libraries or even a completely different programming language.

Because containers are so lightweight and can be started up so quickly, it is also very easy to scale individual containerized services by just starting new instances of the same image and thereby increasing the amount of compute resources a single service can use.
By this, containerized microservices can be scaled in a fine-grained manner in comparison to monolithic applications, because the amount of load an individual component can handle, can now be increased simply by starting new containers of that service, while a monolithic application can only increase the capacity of single components in lockstep with all others.

## Kubernetes as a Deployment Underlay {#sec:kubernetes}

Once an application is split into a suite of microservices and packaged as a set of container images, it needs some infrastructure and platform to be deployed on.
Even though, containerization provides a number of advantages for building microservice-oriented applications, as discussed above, it doesn't solve the problem of running, managing and connecting a fleet of containerized services.
That's where container orchestrators comes into play.

One popular open-source solution for managing high amounts of containers across large clusters of machines is Kubernetes [@k8sio].
Although there are alternative container orchestration solutions, like Docker Swarm, Apache Marathon/Mesos, HashiCorp Nomad, Amazon EC2 Container Service and Azure Container Service, Kubernetes has become the industry's de-facto standard for deploying, managing and scaling containerized applications.

When using Kubernetes, containers are group and managed together as so called **Pods**, which consist of one or multiple interdependent containers modelling a single logical instance of an application component or service. A Pod is the smallest deployable unit in Kubernetes, which will be stored alongside all other Kubernetes objects in a highly-available key-value store (etcd [^etcdio]), accessible via the Kubernetes API.
Kubernetes clusters are composed of a set of physical or virtual machines called Nodes, where individual Pods will be scheduled on to run.

[^etcdio]: \url{https://etcd.io/}

![Kubernetes Architecture [@k8sio]](../assets/k8s-arch.png)

Using Kubernetes as a container orchestration engine for deploying and managing microservice-oriented applications brings several of advantages:

**Resource Management**: Firstly, Kubernetes allows to efficiently manage compute resources used by different service instances. Each container can specify how many compute resources it needs to run properly and the Kubernetes scheduler will find a suitable node in the cluster for running the workload, that has enough free capacity. By this, Kubernetes allows to achieve high resource utilization across all used machines and thereby cutting down cost.

**High-Availability**: One of Kubernetes' core principles is high-availability and self-healing. The self-healing capabilities are achieved by implementing control plane components as controllers, which observe the current state of the workload and take actions to reach the specified desired state. E.g. Kubernetes offers to define application-specific health-checks, which allows to detecting and restarting unhealthy service instances.

**Autoscaling**: Kubernetes provides built-in mechanisms for horizontally scaling individual services in an automated manner. Scaling can either be triggered by resource utilization or by user-defined workload metrics such as requests per second to a given service. Other means of autoscaling like vertically scaling individual services and scaling the cluster itself in the number of nodes are also available by installing additional autoscaling controllers.

**Service Discovery**: Another important feature of Kubernetes, that microservices benefit from is service discovery via simple mechanisms and standard protocols like DNS. Firstly, Kubernetes assigns a unique IP address to each Pod, via which it is reachable by other components in the cluster. Then, applications can group Pods belonging to the same microservice together and make the group reachable via a stable in-cluster DNS entry. Kubernetes will perform basic load balancing between all healthy instances of a service, relieving individual components from the task to figure out where the services they want to talk to are running.

**Network Policies**: Apart from giving each Pod a unique IP address, Kubernetes also allows configuring policies to apply to inter-Pod networking. This can be used to restrict, which of the different microservices can communicate with each other, on which ports and via which protocols. Though, Kubernetes only offers an API for configuring `NetworkPolicies`, enforcement is actually dependent on the networking solution installed in the cluster.

**Automated Rollouts**: When deploying new versions of services, Kubernetes' automated rollout features can help in ensuring smooth rollouts without any downtime. By default, rollouts are done in a rolling update fashion, which means replacing one replica of a given service after another, waiting for the new replicas to be healthy before replacing the next ones. Additionally, rollout strategies can be fine-tuned, e.g. to wait a given number of seconds after a new replica has become ready before continuing with the rollout.

**Uniform and Stable API**: Additionally, Kubernetes provides a uniform and stable API for both workload and configuration management. That means, specifications for workload and its configuration can be accessed, manipulated and secured by the same mechanisms in a stable and compatible manner.

**Infrastructure Abstraction Layer**: Furthermore, Kubernetes acts as an abstraction layer across a lot of infrastructures where one can deploy containerized workload, which makes containerized applications portable and offers flexibility in deployments.
Not only is Kubernetes available as a managed service on many popular cloud platforms, there are also solutions for running it in a private cloud environment and also on a development machine.
Across all these different infrastructures Kubernetes abstracts management of compute, storage and network resources.

<span id="k8s:extensibility"></span>
**Extensibility**: Last but not least, Kubernetes comes with first-class built-in extension mechanisms for extending the Kubernetes API as well as intercepting and altering API requests on the fly. Microservices will not necessarily benefit directly from these mechanisms. Though, Kubernetes' extensible architecture has allowed and fostered a tremendous growth of its open-source community. Over the past few years, a vast number of community-driven projects building on Kubernetes and its extension mechanisms have evolved. One important category of such projects is the service mesh area, which will be introduced later on and can be of great benefit for microservice-oriented applications for overcoming some of their biggest challenges.

## Challenges of Microservices

As presented, there are quite a lot of benefits of implementing a microservice architecture, especially when applications and organizations grow to a large size. Also, teams implementing microservice-oriented architectures can gain a lot from containerization and deployment to a container orchestration engine like Kubernetes.

Nevertheless, there are still some common challenges left, that microservices will face or even bring up. Although the freedom of choice in programming languages and libraries gives a lot of flexibility to development teams, it also makes it hard to implement cross-cutting concerns consistently, particularly those of inter-service communication [@bryant2020servicemesh].

**Remote calls**: First of all, a challenge that arises with a microservices architecture in contrast to a monolithic architecture is that remote calls are always more expensive than in-process function calls. Even if the used protocol in inter-service communication is lightweight, microservices will always be subject to network connection availability, latency and other disruptions. Especially when services invoke a long chain of remote calls, the overall quality of service is susceptible to individual disruptions of inter-service communication.

**Traffic shaping/management**: When deploying a large set of microservice, operators might want to conduct some form of traffic splitting for canary deployments or A/B testing, for example to smoothly rollout new service versions with immediate feedback before breaking the whole application. Also, operators might want to configure common rules across the whole application for service discovery, e.g. which service can talk to which particular instances group of another service.
To make use of such mechanisms, service developers will have to implement them in every single service. Even if the code is moved into a traffic management library, there will still be the need to implement the library in every programming language used in the application. This makes it hard to implement such cross-cutting functionality consistently across all services and also complicates rolling out common changes concerning service discovery and traffic management mechanisms.

**Observability**: If microservices are running in a production environment, it's crucial to have good observability over the whole fleet of microservices and how they perform and behave. Observability is often composed of three main components. Firstly, collecting, visualizing and monitoring metrics about application health, request as well as success rates and similar. Additionally, tracing of request duration as they go through a chain of services is critical for performance analysis and early detection of performance degradation. Finally, access logging can provide valuable data when analysis issues of individual services as well as cascading failures.
All three components are cross-cutting functionality of inter-service communication that has to be implemented by every service or at least every used programming language. The same applies here as for traffic management, it will get hard to implement this functionality consistently across a large fleet of microservices.

**Security**: One last important cross-cutting concern is security, which will be similarly difficult to manage consistently in a microservice architecture. With increased security requirements, individual services might need to offer TLS encryption for inter-service communication as well as mutual authentication of services and countermeasures for denial-of-service attacks. Again, such functionality would have be to coded into each service.
