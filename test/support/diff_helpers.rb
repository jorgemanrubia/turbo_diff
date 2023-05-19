module DiffHelpers
  def assert_changes(expected_changes, changes)
    expected_changes = expected_changes.map(&:with_indifferent_access)
    changes = changes.map(&:with_indifferent_access)

    normalize_html_content_in_changes(expected_changes)
    normalize_html_content_in_changes(changes)

    assert_equal expected_changes, changes
  end

  def parse_html(html_string, strip_blank_spaces: true)
    html_node = if html_string.include?("<html>")
                  Nokolexbor.HTML(html_string)
    else
                  Nokolexbor::DocumentFragment.parse(html_string)
    end

    strip_html_blank_spaces(html_node) if strip_blank_spaces

    html_node
  end

  private
    def normalize_html_content_in_changes(changes)
      changes.each do |change|
        if change[:html]
          change[:html] = parse_html(change[:html]).to_html.strip
        end
      end
    end

    def strip_html_blank_spaces(html_node)
      html_node.traverse do |node|
        if node.text?
          node.content = node.content.strip
          node.remove if node.text.blank?
        end
      end
    end
end
