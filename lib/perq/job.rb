class Perq::Job
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

