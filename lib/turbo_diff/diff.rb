class TurboDiff::Diff
  def initialize(from_html_string, to_html_string)
    @from_html = Nokogiri::HTML5.fragment(from_html_string)
    @to_html = Nokogiri::HTML5.fragment(to_html_string)
  end

  def changes
    change_collector.changes.as_json
  end

  private
    attr_reader :from_html, :to_html

    def change_collector
      @change_collector ||= ChangeCollector.new(from_html, to_html)
    end
end
