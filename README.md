Perq
====

Perq is a (currently very experimental) queuing system that aims to support
large numbers of queues with a limited number of workers where you want each
queue to be processed by only one worker at a time (i.e. serially)

How it works
------------

There's a QueueManager that creates a pool of Workers, both of which are
Celluloid objects. There should only be one running manager per system.
ProjectQueue objects can be created and have jobs pushed to them. When a Job is
pushed onto a ProjectQueue then the queue notifies the manager that it needs
some work done (if it's not already assigned to a worker).

The manager puts the queue on it's list of pending queues to process and tells
the worker pool to process this list. The worker gets a queue from the list and
reserves it for itself. It then processes any jobs on the queue until it's
empty.

Current Wrongness
-----------------

* All in memory, no persistance
* Specs can't really test things actually happened in parallel (and will never
  really be able to properly)
* If queues are being added to faster than workers can process there'll be
  starvation as the workers never finish their assigned queue so some kind of
  timeout or QoS thing is needed.
* Doesn't handle workers or jobs crashing very well
