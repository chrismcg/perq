class Perq::Worker
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
