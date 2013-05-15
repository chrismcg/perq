class Perq::QueueManager
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
