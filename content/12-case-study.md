# Case Study – Lyft

Lyft [^lyftcom] is one of the pioneer companies in the area of service mesh technology. When migrating their existing monolithic application to microservices, the engineering team was confronted with several challenges in further scaling out and maintaining stability of their service. In order to solve these problems, **Lyft created Envoy** [@envoydocs], a modern network proxy, designed to be deployed in a mesh of services.
With this, Lyft has been one of the early adopters and promoters of the service mesh pattern. As the Envoy proxy is an open-source project governed by the Cloud Native Computing Foundation, they are very active members of the cloud-native community and foster joint collaboration on these topics.
In this section, the main problems that Lyft encountered when migrating to microservices are investigated as well as approaches they took to solve those issues with a service mesh.

[^lyftcom]: [https://www.lyft.com/](https://www.lyft.com/)

## The problem

One of the major problems that Lyft faced when transitioning from a monolithic application to a large set of microservices was to deal with cascading failure [@lyftcasestudy]. **Cascading failure** is one of the most difficult challenges in distributed systems, especially for microservice-oriented applications. It describes a class of problems, where small issues in parts of a system like transient network connectivity loss or similar quickly propagate back through the entire interconnected system and eventually can lead to outages of the whole application [@sreworkbook]. Typically, such failures are not recoverable without human intervention, as the system might not self-heal. Problems that can lead to cascading failures when they occur in some parts of a system can be reduced capacity, an increase in latency or a spike in errors. Microservices should be designed in a way to handle such circumstances gracefully, e.g. by automatically retrying failed requests. Though, if a lot of dependent services retry requests for an already overloaded service at the same time, the load is effectively multiplied by many times, which triggers a vicious circle the overloaded service might not be able to recover from. These class of failures are one of the primary causes for unavailability of highly-distributed systems. The key to prevent such failures from cascading through the entire system and to avoid the necessity for human intervention, is to implement proper mechanisms for rate limiting and concurrency control.

Lyft encountered an increased number of such failures in their systems when the number of their microservices running in production increased over time. Thus, some sort of network defense for all of their services was needed to protect them from local overload and to avoid cascading failure in their application. In this endeavor Lyft created Envoy and designed it to be deployed in a meshed network next to every service instance, which is the basic idea for the architecture of a service mesh.
Envoy is handling inter-service communication of both sides of requests, egress as well as ingress. By this, the team is able to configure effective rate limiting and circuit breaking on a per-service basis. This way, every service is equipped with automatic throughput and concurrency protection.

## Rate Limiting

The first pillar of preventing cascading failure is rate limiting. It is a very simple mechanism for preventing overload by too high request rates. In simple terms, rate limiting configures how many events are allowed to happen per second, with events either being connection establishments (e.g. TCP) or requests (e.g. HTTP). Envoy supports two flavors of rate limiting: local and global rate limiting. Local rate limiting is applied on a per-instance-basis of Envoy and protects service instances from being overloaded with high bursts of requests. Additionally, it is possible to limit load based on communication metadata, for example for limiting request rates originating from a given region or IP address.

In contrast, global rate limiting is a mechanism that applies rate limits across a set of service instances, i.e. service proxies. For this a central rate limiting service is required, which individual service proxies consult for rate limiting decisions. This way, service proxies can coordinate overall rate limiting for connections or requests to a given microservice. A common use case for global rate limiting is when a larger number of clients try to communicate with a smaller number of upstream hosts and the average request latency is low. When upstream host have temporarily reduced capacity (e.g. when a database is backed up), local rate limiting is probably not enough and coordination between clients is needed in order to not overload the upstream hosts and prevent cascading failure [@envoydocs].

Lyft primarily uses rate limits to protect their services from unexpected and malicious load, for example by limiting requests rate based on the requests' user ID.

## Concurrency control

The second pillar of preventing cascading failure is effective concurrency control. Concurrency describes how many units can be in use simultaneously. This might be how many parallel connections to an upstream host can be established, how many requests can be concurrently in-flight or how many request can be enqueued waiting for an available connection at any given point in time.
Envoy is able to effectively manage concurrency via distributed circuit breaking. Circuit breaking is a mechanism, that limits how many connection and requests can be made at any given point in time and applies back-pressure when the limit overflows, i.e. more connection and request attempts are made. This is very important in a distributed system, because it protects workload from queueing up many requests, increased latency and eventually resource starvation and thus also contributes to avoiding cascading failure [@envoydocs].

Lyft mainly employs circuit breaking for managing concurrency at two points in their service mesh: for ingress traffic from the service proxy to the application and on egress traffic to peer services via the proxy. As every service in the application is running with Envoy as a sidecar proxy, the number of concurrent connections from the proxy to the application can be configured easily and concurrency of incoming connections and requests can be limited.

Implementations

- rate limiting
  - monitored for every rate limit configuration
- concurrency
  - at ingress: maximum concurrent connections from envoy to application
  - at egress: maximum concurrent requests per service
  - easier to track down undesired behavior (e.g. burstiness)
  - monitored
    - experiment with / figure out the right limits
    - monitor applied limits

Shortcomings

- hard to pick a nominal limit (rate limits and concurrency)
  - concurrency limits are local
  - maximum has to be taken into account
  - visualizing helps
- concurrency is very non-intuitive for most developers
- hard to keep up with change
  - continuous delivery of services
  - in-flight concurrency might be increased, when dependency slows down
  - joint effort with netflix for making limits adaptive in envoy L7 filters
