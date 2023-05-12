class TurboDiff::Diff
  def initialize(from_html, to_html)
    @from_html = from_html
    @to_html = to_html
  end

  def changes
    @changes ||= Changes.new(from_html, to_html)
  end

  private
    attr_reader :from_html, :to_html
end
