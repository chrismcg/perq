class Perq::Job
  attr_reader :name

  def initialize(name)
    @ran = false
    @name = name
  end

  def run(queue_name)
    raise "Need to implement the run method"
  end

  def ran?
    @ran
  end
end
