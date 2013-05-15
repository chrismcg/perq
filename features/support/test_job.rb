class Perq::TestJob < Perq::Job
  def initialize(name)
    super
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
    $output[queue_name] << self.name
    @ran = true
    @condvar.signal
  end
end
