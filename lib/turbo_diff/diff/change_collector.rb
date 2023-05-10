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

      # from_html.children.each_with_index do |from_child, index|
      #   to_child = to_html.children[index]
      #
      #   if from_child.nil?
      #     changes << TurboDiff::Diff::Change.new(:insert, to_child)
      #   elsif to_child.nil?
      #     changes << TurboDiff::Diff::Change.new(:delete, from_child)
      #   elsif from_child.name != to_child.name
      #     changes << TurboDiff::Diff::Change.new(:replace, from_child, to_child)
      #   elsif from_child.text? && to_child.text?
      #     if from_child.text != to_child.text
      #       changes << TurboDiff::Diff::Change.new(:replace, from_child, to_child)
      #     end
      #   elsif from_child.name == to_child.name
      #     collect_changes_for_same_named_children(from_child, to_child)
      #   end
      # end
    end

    def add_changes(from_node, to_node, cursor)
      unless equal_nodes?(from_node, to_node)
        changes << TurboDiff::Change.new(:replace, cursor.to_s, html: to_node.to_html)
      end

      from_node.element_children.each_with_index do |from_child, index|
        to_child = to_node.element_children[index]
        add_changes(from_child, to_child, cursor.down)
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
