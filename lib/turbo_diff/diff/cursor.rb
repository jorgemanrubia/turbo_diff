class TurboDiff::Diff::Cursor
  attr_reader :positions

  def initialize(positions = [ 0 ])
    @positions = positions
  end

  def down
    self.class.new(positions + [ 0 ])
  end

  def to_s
    @positions.join("/")
  end
end
