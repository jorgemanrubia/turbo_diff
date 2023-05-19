class TurboDiff::Diff::Changes
  delegate :as_json, to: :changes

  def initialize(from_html, to_html)
    @from_html = from_html
    @to_html = to_html
    @changes = []
    @cursor = TurboDiff::Diff::Cursor.new

    collect_changes
  end

  private
    attr_reader :changes, :cursor

    def collect_changes
      add_changes(@from_html.first_element_child, @to_html.first_element_child, cursor)
    end

    def add_changes(from_node, to_node, cursor)
      if from_node && to_node
        if equal_nodes?(from_node, to_node)
          add_changes_from_children(from_node, to_node, cursor)
        elsif same_name?(from_node, to_node)
          add_attribute_changes(from_node, to_node, cursor)
          add_changes_from_children(from_node, to_node, cursor)
        else
          changes << TurboDiff::Change.replace(cursor.to_selector, **change_properties_for(to_node))
        end
      elsif !to_node
        changes << TurboDiff::Change.delete(cursor.to_selector)
      elsif !from_node
        changes << TurboDiff::Change.insert(cursor.to_selector, **change_properties_for(to_node))
      end
    end

    def add_changes_from_children(from_node, to_node, cursor)
      for_each_children(from_node, to_node) do |from_child, to_child, index|
        add_changes(from_child, to_child, cursor.down(index))
      end
    end

    def for_each_children(from_node, to_node)
      map_nodes(diffable_nodes(from_node.children), diffable_nodes(to_node.children)).each.with_index do |(from_child, to_child), index|
        yield from_child, to_child, index
      end
    end

    def diffable_nodes(nodes)
      nodes.find_all { |node| (node.text? && node.text.present?) || node.element? }
    end

    def map_nodes(from_nodes, to_nodes)
      mapped_nodes = []

      to_nodes_by_id = to_nodes.group_by { |node| node["id"] }
      processed_to_nodes = Set.new
      processed_from_nodes = Set.new

      # Matching "from" by id has priority
      from_nodes.each do |from_node|
        if matched_to_node = to_nodes_by_id[from_node["id"]]&.shift

          # Add missing nodes before the matched node
          index = to_nodes.index(matched_to_node)
          0.upto(index - 1) do |i|
            to_node = to_nodes[i]
            next if processed_to_nodes.include?(to_node)

            mapped_nodes << [ nil, to_node ]
            processed_to_nodes << to_node
          end

          # Process the node matched by id
          mapped_nodes << [ from_node, matched_to_node ]
          processed_to_nodes << matched_to_node
          processed_from_nodes << from_node
        end
      end

      # Rest of "from" nodes
      from_nodes.each.with_index do |from_node, index|
        to_node = to_nodes[index]
        next if processed_from_nodes.include?(from_node) || processed_to_nodes.include?(to_node)

        # If same position, name and attributes, we consider it a match
        if equal_nodes?(from_node, to_node)
          mapped_nodes << [ from_node, to_node ]
          processed_to_nodes << to_node
        else
          mapped_nodes << [ from_node, nil ]
        end
        processed_from_nodes << from_node
      end

      # Rest of "to" nodes
      to_nodes.each do |to_node|
        next if processed_to_nodes.include?(to_node)
        mapped_nodes << [ nil, to_node ]
        processed_to_nodes << to_node
      end

      mapped_nodes
    end

    def add_attribute_changes(from_node, to_node, cursor)
      from_attributes = from_node.attributes.transform_values(&:value)
      to_attributes = to_node.attributes.transform_values(&:value)

      attributes = {}
      deleted_attributes = []

      from_attributes.each do |name, from_attribute|
        if !to_node[name]
          deleted_attributes << name
        elsif from_attribute[name] != to_attributes[name]
          attributes[name.to_sym] = to_attributes[name]
        end
      end

      to_attributes.without(*from_attributes.keys).each do |name, to_attribute|
        attributes[name.to_sym] = to_attributes[name]
      end

      change_properties = { added: attributes.presence, deleted: deleted_attributes.presence }.compact

      unless change_properties.empty?
        changes << TurboDiff::Change.attributes(cursor.to_selector, **change_properties)
      end
    end

    def equal_nodes?(node_1, node_2)
      if node_1 && node_2 && node_1.type == node_2.type
        if node_1.element?
          same_name?(node_1, node_2) && same_attributes?(node_1, node_2)
        else
          same_text?(node_1, node_2)
        end
      end
    end

    def same_name?(node_1, node_2)
      node_1.element? && node_2.element? && node_1.name == node_2.name
    end

    def same_attributes?(node_1, node_2)
      node1_attributes = node_1.attributes.transform_values(&:value)
      node2_attributes = node_2.attributes.transform_values(&:value)

      node1_attributes == node2_attributes
    end

    def same_text?(node_1, node_2)
      node_1.text? && node_2.text? && node_1.text == node_2.text
    end

    def change_properties_for(node)
      if node.element?
        { html: node.to_html }
      else
        { text: node.text.strip }
      end
    end
end
