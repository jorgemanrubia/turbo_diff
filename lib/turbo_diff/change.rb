class TurboDiff::Change
  attr_reader :selector, :type, :data

  def initialize(type, selector, **data)
    @type = type
    @selector = selector
    @data = data
  end

  def to_s
    "#{type}@#{selector}: #{data.inspect}"
  end

  alias inspect to_s

  def as_json
    { type: type, selector: selector }.merge(data)
  end
end
