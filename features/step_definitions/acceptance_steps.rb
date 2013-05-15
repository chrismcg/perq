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
