class TurboDiff::Diff::ChangeCollector
  attr_reader :changes

  def initialize(from_html, to_html)
    @from_html = from_html
    @to_html = to_html
    @changes = []
    @cursor = TurboDiff::Diff::Cursor.new

    collect_changes
  end

  private
    attr_reader :cursor

    def collect_changes
      add_changes(@from_html.first_element_child, @to_html.first_element_child, cursor)
    end

    def add_changes(from_node, to_node, cursor)
      unless equal_nodes?(from_node, to_node)
        changes << TurboDiff::Change.replace(cursor.to_selector, html: to_node.to_html)
      end

      from_node.element_children.each_with_index do |from_child, index|
        to_child = to_node.element_children[index]
        add_changes(from_child, to_child, cursor.down(index))
      end
    end

    def equal_nodes?(node_1, node_2)
      if node_1 && node_2
        node_1.name == node_2.name && same_attributes?(node_1, node_2)
      end
    end

    def same_attributes?(node_1, node_2)
      node_1.attributes == node_2.attributes
    end
end
