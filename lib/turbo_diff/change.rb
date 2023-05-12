class TurboDiff::Change
  attr_reader :selector, :type, :data

  CHANGE_TYPES = %i[ replace insert attributes ]

  class << self
    CHANGE_TYPES.each do |change_type|
      define_method change_type do |selector, **data|
        new(change_type, selector, **data)
      end
    end
  end

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
