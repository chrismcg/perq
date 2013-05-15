class Perq::ProjectQueue
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

