module Perq
	class Job
		def initialize(name)
			@ran = false
			@name = name
			@condvar = ConditionVariable.new
			@mutex = Mutex.new
		end

		def wait
			@mutex.synchronize do
				return if ran?
				@condvar.wait(@mutex)
			end
		end

		def run(queue_name)
			$output[queue_name] << @name
			@ran = true
			@condvar.signal
		end

		def ran?
			@ran
		end
	end

	class ProjectQueue
		attr_reader :name

		def initialize(manager, name)
			@backend = ::Queue.new
			@manager = manager
			@name = name
			@reserved = false

			@mutex = Mutex.new
		end

		def push(job)
			# validate input
			@backend.push(job)

			if ! reserved?
				@manager.async.dirty_queue(self)
			end
		end

		def pop
			@backend.pop(0)
		rescue ThreadError
		end

		def reserve
			@mutex.synchronize do
				@reserved = true
			end
		end

		def unreserve
			@mutex.synchronize do
				@reserved = false
			end
		end

		def reserved?
			@mutex.synchronize do
				@reserved
			end
		end
	end

	class PendingQueue
		def initialize
			@backend = ::Queue.new
			@mutex = Mutex.new
		end

		def push(queue)
			@backend.push(queue)
		end

		def reserve
			pq = @mutex.synchronize do
				project_queue = @backend.pop
				project_queue.reserve
				project_queue
			end

			yield pq

		ensure
			pq.unreserve
		end
	end

	class QueueManager
		include Celluloid

		attr_reader :pending_queues
		def initialize(pool_size = 30)
			@pending_queues = Perq::PendingQueue.new
			@worker_pool = Perq::Worker.pool(args: self, size: pool_size)
		end

		def dirty_queue(project_queue)
			@pending_queues.push(project_queue)
			@worker_pool.async.process_pending_queue
		end
	end

	class Worker
		include Celluloid

		def initialize(manager)
			@manager = manager
		end

		def process_pending_queue
			@manager.pending_queues.reserve do |project_queue|
				while job = project_queue.pop
					job.run(project_queue.name)
				end
			end
		end
	end
end

Before do
	$output = Hash.new { |h, k| h[k] = [] }
end

Given(/^a queue and two workers$/) do
  @queue_manager = Perq::QueueManager.new(2)
	@project_queue = Perq::ProjectQueue.new(@queue_manager, "queue")
end

When(/^I add one job to the queue$/) do
	@job = Perq::Job.new("job1")
	@project_queue.push(@job)
end

Then(/^the job should get run$/) do
	@job.wait
	expect(@job.ran?).to be_true
end

When(/^I add two jobs to the queue$/) do
	@job1 = Perq::Job.new("job1")
	@project_queue.push(@job1)
	@job2 = Perq::Job.new("job2")
	@project_queue.push(@job2)
end

Then(/^the jobs should be run serially in the order they were added to the queue$/) do
	@job1.wait
	@job2.wait
  expect($output["queue"]).to eql(["job1", "job2"])
end

Given(/^two queues and two workers$/) do
  @queue_manager = Perq::QueueManager.new(2)
	@project_queue1 = Perq::ProjectQueue.new(@queue_manager, "queue1")
	@project_queue2 = Perq::ProjectQueue.new(@queue_manager, "queue2")
end

When(/^I add one job to each queue$/) do
	@job1 = Perq::Job.new("job1")
	@project_queue1.push(@job1)
	@job2 = Perq::Job.new("job2")
	@project_queue2.push(@job2)
end

Then(/^the jobs should be run in parallel$/) do
	@job1.wait
	@job2.wait
	expect($output["queue1"]).to eql(["job1"])
	expect($output["queue2"]).to eql(["job2"])
end

When(/^I add two jobs to each queue$/) do
	@job1q1 = Perq::Job.new("job1q1")
	@job2q1 = Perq::Job.new("job2q1")
	@project_queue1.push(@job1q1)
	@project_queue1.push(@job2q1)
	@job1q2 = Perq::Job.new("job1q2")
	@job2q2 = Perq::Job.new("job2q2")
	@project_queue2.push(@job1q2)
	@project_queue2.push(@job2q2)
end

Then(/^each queues jobs should be run serially in the order they were added to the queue but both queues job should be executing in parallel$/) do
	@job1q1.wait
	@job2q1.wait
	@job1q2.wait
	@job2q2.wait
	expect($output["queue1"]).to eql(["job1q1", "job2q1"])
	expect($output["queue2"]).to eql(["job1q2", "job2q2"])
end

Given(/^a queue and a worker$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I add a bad job to the queue with a retry count of (\d+)$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^the job should get run three times then marked as failed$/) do
  pending # express the regexp above with the code you wish you had
end
