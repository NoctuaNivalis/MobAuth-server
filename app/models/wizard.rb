class Wizard

  def initialize(steps, session)
    @steps = steps
    @session = session
  end

  def first
    self.step = 0
  end

  def current
    @steps[step]
  end

  def next
    self.step = [@steps.size, step + 1].min
  end

  def previous
    self.step = [0, step - 1].max
  end

  def last?
    step == @steps.size - 1
  end

  def first?
    step == 0
  end

  private

  def step
    @session[:linking_step] || 0
  end

  def step=(s)
    @session[:linking_step] = s
  end

end
