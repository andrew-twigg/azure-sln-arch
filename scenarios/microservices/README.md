# Microservices

## Description

An architectural style that structures an application as a collection of independently deployable services that are modelled around a business domain and are usually owned by a small team.

## When to use microservices

* Fine to start with a monolith, then move to microservices
* Start looking at microservices when:
    * The codebse size is more that what a small team can maintain
    * Teams can't move fast anymore
    * Builds become too slow due to large codebase
    * Time to market is compromised due to infrequent deployments and long verification times
* It's all about autonomy

## Monolith pros and cons

| Pros                             | Cons                                   |
|----------------------------------|----------------------------------------|
| Convenient for new projects      | Easily gets too conplex to understand  |
| Tools mostly focused on them     | Merging code can be challenging        |
| Grest code reuse                 | Slows down IDEs                        |
| Easier to run locally            | Long build times                       |
| Easier to debug and troubleshoot | Slow and infrequent deployments        |
| One thing to build               | Long testing and stabilisation periods |
| One thing to deploy              | Rolling back is all or nothing         |
| One thing to test end-to-end     | No isolation between modules           |
| One thing to scale               | Can be hard to scale                   |
|                                  | Hard to adopt new tech                 |

## Microservices pros and cons

| Pros                                                    | Cons                                        |
|---------------------------------------------------------|---------------------------------------------|
| Small, easier to understand codebase                    | Not easy to find the right set of services  |
| Quicker to build                                        | Adds the complexity of distributed systems  |
| Independent, faster deployments and rollbacks           | Shared code moves to separate libraries     |
| Independently scalable                                  | No good tooling for distributed apps        |
| Much better isolation from failures                     | Releasing features across services is hard  |
| Designed for continuous delivery                        | Hard to troubleshoot issues across services |
| Easier to adopt new, varied tech                        | Can't use transactions across services      |
| Grants autonomy to teams and lets them work in parallel | Raises the required skillset for the team   |
