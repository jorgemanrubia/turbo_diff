class TurboDiff::Diff::Cursor
  attr_reader :positions

  def initialize(positions = [ 0 ])
    @positions = positions
  end

  def down(index)
    self.class.new(positions + [ index ])
  end

  def to_selector
    @positions.join("/")
  end

  alias to_s to_selector
end
