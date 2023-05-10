class TurboDiff::Diff
  def initialize(from_html_string, to_html_string)
    @from_html = Nokogiri::HTML5.fragment(from_html_string)
    @to_html = Nokogiri::HTML5.fragment(to_html_string)
  end

  def changes
    @changes ||= Changes.new(from_html, to_html)
  end

  private
    attr_reader :from_html, :to_html
end
