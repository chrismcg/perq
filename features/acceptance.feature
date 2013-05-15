Feature: Per project queue
  So that I can serialize access to a shared data structure
  Without having to run a worker per project
  I want to be able to have a persisted queue per project and a pool of workers
  I want only one worker to be processing a projects queue at a time and if it dies the job will be retried up to a limit

  Scenario: Processing a single job on a single queue
    Given a queue and two workers
    When I add one job to the queue
    Then the job should get run

  Scenario: Processing two jobs on a single queue
    Given a queue and two workers
    When I add two jobs to the queue
    Then the jobs should be run serially in the order they were added to the queue

  Scenario: Processing a single job on each of two queues
    Given two queues and two workers
    When I add one job to each queue
    Then the jobs should be run in parallel

  Scenario: Processing two jobs on each of two projects
    Given two queues and two workers
    When I add two jobs to each queue
    Then each queues jobs should be run serially in the order they were added to the queue but both queues job should be executing in parallel

  @wip
  Scenario: Handling a failing job
    Given a queue and a worker
    When I add a bad job to the queue with a retry count of 2
    Then the job should get run three times then marked as failed
