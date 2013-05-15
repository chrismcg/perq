class Perq::PendingQueue
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

