# Case Study – Lyft

Lyft [^lyftcom] is one of the pioneering companies in the area of service mesh technology. When migrating their existing monolithic application to microservices, the engineering team was confronted with several challenges in further scaling out and maintaining stability of their service. In order to solve these problems, **Lyft created Envoy** [@envoydocs], a modern network proxy, designed to be deployed in a mesh of services.
With this, Lyft has been one of the early adopters and promoters of the service mesh pattern. As the Envoy proxy is an open-source project governed by the Cloud Native Computing Foundation, they are very active members of the cloud-native community and foster joint collaboration on these topics.
In this section, the main problems that Lyft encountered when migrating to microservices are investigated as well as approaches they took to solve those issues with a service mesh.

[^lyftcom]: [https://www.lyft.com/](https://www.lyft.com/)

## The problem

One of the major problems that Lyft faced when transitioning from a monolithic application to a large set of microservices was to deal with cascading failure [@lyftcasestudy]. **Cascading failure** is one of the most difficult challenges in distributed systems, especially for microservice-oriented applications. It describes a class of problems, where small issues in parts of a system like transient network connectivity loss or similar quickly propagate back through the entire interconnected system and eventually can lead to outages of the whole application [@sreworkbook]. Usually, such failures are not recoverable without human intervention, as the system might not self-heal.
Typical problems that can lead to cascading failures when occurring in some parts of a system are reduced capacity, an increase in latency or a spike in errors. Microservices should be designed in a way to handle such circumstances gracefully, e.g. by automatically retrying failed requests.
Though, if a lot of dependent services retry requests for an already overloaded service at the same time, the load is effectively multiplied, which triggers a vicious circle the overloaded service might not be able to recover from.
This class of failures are one of the primary causes for unavailability of highly-distributed systems. The key to prevent such failures from cascading through the entire system and to avoid the necessity for human intervention, is to implement proper mechanisms for rate limiting and concurrency control.

Lyft encountered an increased number of such failures in their systems when the number of their microservices running in production increased over time. Thus, some sort of network defense for all of their services was needed to protect them from local overload and to avoid cascading failure in their application. In this endeavor Lyft created Envoy and designed it to be deployed in a meshed network next to every service instance, which is the basic idea behind the service mesh pattern.
Envoy is handling inter-service communication on both sides of requests, egress as well as ingress. By this, the team is able to configure effective rate limiting and circuit breaking on a per-service basis. This way, every service is equipped with automatic throughput and concurrency protection. With this approach the Lyft team has been able to solve the problem of cascading failure in their application and reduced the number of load-based incidents that are noticeable by users by about 95%.

## Rate Limiting

The first pillar of preventing cascading failure is rate limiting. It is a very simple mechanism for preventing overload by too high request rates. In simple terms, rate limiting configures how many events are allowed to happen per second, with events either being connection establishments (e.g. TCP) or requests (e.g. HTTP). Envoy supports two flavors of rate limiting: local and global rate limiting. Local rate limiting is applied on a per-instance-basis of Envoy and protects service instances from being overloaded with high bursts of requests. Additionally, it is possible to limit load based on communication metadata, for example for limiting request rates originating from a given region or IP address.

In contrast, global rate limiting is a mechanism that applies rate limits across a set of service instances, i.e. service proxies. For this, a central rate limiting service is required, which individual service proxies consult for rate limiting decisions. This way, service proxies can coordinate overall rate limiting for connections or requests to a given microservice.
A common use case for global rate limiting is when a larger number of clients try to communicate with a smaller number of upstream hosts and the average request latency is low. When upstream hosts have temporarily reduced capacity, e.g. when a database is backed up, local rate limiting in calling clients is probably not enough and coordination between clients is needed in order to not overload the upstream hosts and prevent cascading failure [@envoydocs].

Lyft primarily uses rate limits to protect their services from unexpected and malicious load, for example by limiting requests rate based on the requests' user ID.

## Concurrency control

The second pillar of preventing cascading failure is effective concurrency control. Concurrency describes how many units can be in use simultaneously. This might be how many parallel connections to an upstream host can be established, how many requests can be concurrently in-flight or how many request can be enqueued waiting for an available connection at any given point in time.
Envoy is able to effectively manage concurrency via distributed circuit breaking. Circuit breaking is a mechanism, that limits how many connection and requests can be made at any given point in time and applies back-pressure when the limit overflows, i.e. more connection and request attempts are made. This is very important in a distributed system, because it protects workload from queueing up too many requests, increased latency which might eventually lead to resource starvation and thus can also cause cascading failure [@envoydocs].

Lyft mainly employs circuit breaking for managing concurrency at two points in their service mesh: for ingress traffic from the service proxy to the application and on egress traffic to peer services via the proxy. As every service in the application is running with Envoy as a sidecar proxy, the number of concurrent connections from the proxy to the application can be configured easily and concurrency of incoming connections and requests can be limited. Also, as all traffic leaving a service is routed through envoy, the same concurrency control mechanisms can be used for egress traffic as well. With this, the number of concurrent outgoing connections originating from one service can be configured for each upstream service. With both points combined, concurrency control is enforced for all inter-service communication in the entire service mesh.

## Monitoring

With both rate limiting and concurrency control in place, concrete configuration of the enforced limits are needed. As it is hard to pick nominal limits without knowing all constraints of a distributed system, Lyft consult monitoring data from all service proxies for figuring out suitable limits. With this, service owners are able to see how their service behaves in production and how many incoming and outgoing connections and requests are done, thereby enabling them to choose sensible limits. For example, Lyft has created dashboards for rate limiting, that show incoming request rates for each service including aggregation by the requesting service and overflow metrics. Additionally, Lyft utilizes interactive dashboards, where service owners can experiment with limits for concurrency control, that then show which calling services actually makes more requests than a given limit.

![Envoy rate limit dashboard [@lyftcasestudy]](../assets/lyft-dashboard-rate-limits.jpg)

\newpage

When both rate limit and concurrency control limits are applied, there are dashboards for visualizing limit overflows as well. These dashboards enable detecting, when limits have to be increased to cater with the actual load. Also, by observing heavy communication that is limited by the various mechanisms, developers and operators are able to track down undesired behavior (e.g. burstiness in specific services) more easily.

## Shortcomings

Although Lyft has been able to solve most cases of cascading failures with implementation the service mesh pattern, they also describe some shortcomings with this approach of rate limiting and concurrency control.
First of all, they describe that concurrency control can be a counterintuitive concept for most developers, because they tend to only think of load by means of requests per second. Though, visualizing concurrent requests in dashboards helps grasp the concept of concurrency, it's still not completely intuitive.
Additionally, they say it is really hard to pick the right limits for both mechanisms. One reason for this is, that concurrency limits are applied locally, which means that they have to take the maximum possible value into account rather than the average in order to allow temporary load spikes on single instances and not apply back-pressure too early.

Another factor making it difficult to pick the right limits is constant change. Lyft is heavily leveraging continuous deployment pipelines, meaning there are hundreds of deployments per day. Each deployment may change the constraints of the system under which it operates and its resource and load profile. This basically immediately renders the picked limits outdated.

Also, if a peer service is slowed down by a noticeable percentage, the number of allowed concurrent requests to that service from a dependent service might need to be increased, because it is waiting longer for responses now.
As Envoy can only enforce static concurrency limits, it becomes quite difficult to achieve optimal throughput and latency in highly-dynamic environments. That's why, there is an ongoing joint effort with Netflix [^concurrencylimits] on applying well-established concepts from TCP congestion control to dynamic concurrency control in distributed systems, which can allow better throughput and latency.

[^concurrencylimits]: See the open-source library [https://github.com/Netflix/concurrency-limits](https://github.com/Netflix/concurrency-limits) for more details.
