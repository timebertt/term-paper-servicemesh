# Case Study

Lyft early service mesh practitioner and promoter (via Envoy)
Case study: [@lyftcasestudy]

- cascading failure [@sreworkbook]
  - issues propagating back via feedback through entire application
  - often caused by small transient problems
  - won't self-heal, human intervention needed
  - reduction in capacity, increase in latency, spike in errors
- rate limiting, proper retry mechanisms needed
- one of the primary causes for unavailability

- lyft faced cascading failure issues when migrating to microservices
- throughput and concurrency protection
- network defense via Envoy, deployed on both sides of the request
- rate limiting, circuit breaking -> protect from overload
