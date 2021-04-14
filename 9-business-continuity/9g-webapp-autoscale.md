# Dynamically meet changing web app performance requirements with autoscale rules

Respond to periods of high activity by incrementally adding resources, and then removing these resources when activity drops, to reduce costs.

- Enables a system to adjust resources required to meet varying demand
- Controls the costs associated with resources
- Supported on many Azure services including web apps


## Scenarios for autoscaling

- Trigger according to a schedule or resource measure
    - CPU
    - memory occupancy
    - incoming request surge
    - combination of factors
- Cloud system or process that adjusts available resources based on demand
    - scale in / out
    - not up / down
- Two options for autoscaling
    - based on metric
    - specific instance count according to a schedule
    - create multiple autoscale conditions to handle different schedules and metrics
- Analyses metrics
    - analyses trends in metric values over time across all instances
    - multistep process
        - **first step** an autoscale rule aggregates the values retrieved for a metric for all instances across a period of time known as the *time grain*. Each instance has its own time grain. Aggr value is known as *time aggregation*, average, minimum, maximum, total, last, and count.
        - **second step** performs a further aggregation of the value calculated by *time aggregation* over a longer, user-specified period, known as the *Duration*.

