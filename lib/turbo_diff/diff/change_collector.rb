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
      if from_node && to_node
        if equal_nodes?(from_node, to_node)
          add_changes_from_children(from_node, to_node, cursor)
        else
          changes << TurboDiff::Change.replace(cursor.to_selector, html: to_node.to_html)
        end
      elsif !from_node
        changes << TurboDiff::Change.insert(cursor.to_selector, html: to_node.to_html)
      end
    end

    def add_changes_from_children(from_node, to_node, cursor)
      for_each_children(from_node, to_node) do |from_child, to_child, index|
        add_changes(from_child, to_child, cursor.down(index))
      end
    end

    def for_each_children(from_node, to_node)
      map_nodes(from_node.element_children, to_node.element_children).each.with_index do |(from_child, to_child), index|
        yield from_child, to_child, index
      end
    end

    def map_nodes(from_nodes, to_nodes)
      mapped_nodes = []

      to_nodes_by_id = to_nodes.group_by { |node| node["id"] }
      processed_to_nodes = Set.new
      processed_from_nodes = Set.new

      # By id
      from_nodes.each do |from_node|
        if matched_to_node = to_nodes_by_id[from_node["id"]].shift
          mapped_nodes << [from_node, matched_to_node]
          processed_to_nodes << matched_to_node
          processed_from_nodes << from_node
        end
      end

      # Rest of from nodes
      from_nodes.each.with_index do |from_node, index|
        to_node = to_nodes[index]
        next if processed_from_nodes.include?(from_node) || processed_to_nodes.include?(to_node)

        if equal_nodes?(from_node, to_node)
          mapped_nodes << [from_node, to_node]
          processed_to_nodes << to_node
        else
          mapped_nodes << [from_node, nil]
        end
        processed_from_nodes << from_node
      end

      # Rest of to nodes
      to_nodes.each do |to_node|
        next if processed_to_nodes.include?(to_node)
        mapped_nodes << [nil, to_node]
        processed_to_nodes << to_node
      end

      mapped_nodes
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
