class Form::Item < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Item",
            uri_suffix: "I",
            uri_unique: true

  data_property :ordinal, default: 1
  data_property :note
  data_property :completion
  data_property :optional, default: false

  validates_with Validator::Field, attribute: :ordinal, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :note, method: :valid_markdown?
  validates_with Validator::Field, attribute: :completion, method: :valid_markdown?
  validates :optional, inclusion: { in: [ true, false ] }

  include Form::Ordinal

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/BusinessForm#hasGroup>",
      "<http://www.assero.co.uk/BusinessForm#hasSubGroup>*",
      "<http://www.assero.co.uk/BusinessForm#hasCommon>?",
      "<http://www.assero.co.uk/BusinessForm#hasItem>",
      "<http://www.assero.co.uk/BusinessForm#hasCommonItem>*"
    ]
  end

  # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
  #
  # @return [Symbol] the predicate property as a symbol
  def managed_ancestors_predicate
    :has_item
  end

  # Delete. Delete the object. Clone if there are multiple parents.
  #
  # @param [Object] parent_object the parent object
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Object] the parent object, either new or the cloned new object with updates
  def delete(parent, managed_ancestor)
    if multiple_managed_ancestors?
      parent = clone_and_unlink(managed_ancestor)
    else
      delete_node(parent)
    end
    normal_group = Form::Group::Normal.find_full(parent.uri)
    normal_group = normal_group.full_data
  end

  def clone_and_unlink(managed_ancestor)
    tx = transaction_begin
    new_parent = nil
    uris = managed_ancestor_path_uris(managed_ancestor)
    prev_object = managed_ancestor
    prev_object.transaction_set(tx)
    uris.each do |old_uri|
      old_object = self.class.klass_for(old_uri).find_children(old_uri)
      cloned_object = clone_and_save(old_object, prev_object, tx)
      if self.uri == old_object.uri  
        prev_object.delete_link(old_object.managed_ancestors_predicate, old_object.uri)
        new_parent = prev_object
        new_parent.clone_children_and_save_no_tx(tx)
      else 
        prev_object.replace_link(old_object.managed_ancestors_predicate, old_object.uri, cloned_object.uri)
      end
      prev_object = cloned_object
    end
    transaction_execute
    new_parent.reset_ordinals
    new_parent = Form::Group.find_full(new_parent.id)
  end

  def delete_node(parent)
    update_query = %Q{
      DELETE DATA
      {
        #{parent.uri.to_ref} bf:hasItem #{self.uri.to_ref} 
      };
      DELETE {?s ?p ?o} WHERE 
      { 
        { BIND (#{self.uri.to_ref} as ?s). 
          ?s ?p ?o
        }
        UNION
        { #{self.uri.to_ref} bf:hasCodedValue ?o1 . 
          BIND (?o1 as ?s) . 
          ?s ?p ?o .
        }
        UNION
        { #{self.uri.to_ref} bf:hasProperty ?o2 . 
          BIND (?o2 as ?s) . 
          ?s ?p ?o .
        }
      }
    }
    partial_update(update_query, [:bf])
    parent.reset_ordinals
    1
  end

  def move_up_with_clone(child, managed_ancestor)
    if multiple_managed_ancestors?
      parent_and_child = clone_nodes(child, managed_ancestor)
      parent_and_child.first.move_up(parent_and_child.second)
    else
      move_up(child)
    end
  end

  def move_down_with_clone(child, managed_ancestor)
    if multiple_managed_ancestors?
      parent_and_child = clone_nodes(child, managed_ancestor)
      parent_and_child.first.move_down(parent_and_child.second)
    else
      move_down(child)
    end
  end

  def clone_nodes(child, managed_ancestor)
    new_parent = nil
    new_object = nil
    tx = transaction_begin
    uris = child.managed_ancestor_path_uris(managed_ancestor)
    prev_object = managed_ancestor
    prev_object.transaction_set(tx)
    uris.each do |old_uri|
      old_object = self.class.klass_for(old_uri).find_children(old_uri)
      if old_object.multiple_managed_ancestors?
        cloned_object = clone_and_save(old_object, prev_object, tx)
        if child.uri == old_object.uri
          new_parent = prev_object
          new_object = new_parent.clone_children_and_save_no_tx(tx, child.uri) 
        end
        prev_object.replace_link(old_object.managed_ancestors_predicate, old_object.uri, cloned_object.uri)
        prev_object = cloned_object
      else
        prev_object = old_object
      end
    end
    transaction_execute
    new_parent = Form::Item.find_full(new_parent.id)
    return new_parent, new_object
  end

  # # Clone the children and create.
  # #   The Children are normally references. Also note the setting of the transaction in the cloned object and
  # #   in the sparql generation, important both are done.
  # def clone_children_and_save(tx, uri = nil)
  #   sparql = Sparql::Update.new(tx)
  #   new_object = nil
  #   set = self.has_coded_value
  #   set.each do |child|
  #     object = child.clone
  #     object.transaction_set(tx)
  #     object.generate_uri(self.uri) 
  #     object.to_sparql(sparql, true)
  #     self.replace_link(child.managed_ancestors_predicate, child.uri, object.uri)
  #     unless uri.nil? 
  #       new_object = object if child.uri == uri 
  #     end 
  #   end
  #   sparql.create
  #   new_object
  # end

  def start_row(optional)
    return '<tr class="warning">' if optional
    return '<tr>'
  end

  def end_row
    return "</tr>"
  end

  def markdown_row(markdown)
    return "<tr><td colspan=\"3\"><p>#{MarkdownEngine::render(markdown)}</p></td></tr>"
  end

  def question_cell(text)
    return "<td>#{text}</td>"
  end

  def mapping_cell(text, options)
    return "<td>#{text}</td>" if !text.empty? && options[:annotate]
    return empty_cell
  end

  def empty_cell
    return "<td></td>"
  end

  # Format input field
  def input_field(item)
    html = '<td>'
    datatype = nil
    if item.class == BiomedicalConcept::PropertyX
      if item.is_complex_datatype_property.nil?
        datatype = nil
      else
        prop = ComplexDatatype::PropertyX.find(item.is_complex_datatype_property)
        datatype = XSDDatatype.new(prop.simple_datatype)
      end
    else
      datatype = XSDDatatype.new(item.datatype)
    end
    if datatype.nil?
      html += field_table(["?", "?", "?"])
    elsif datatype.datetime?
      html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y", "", "H", "H", ":", "M", "M"])
    elsif datatype.date?
     html += field_table(["D", "D", "/", "M", "M", "M", "/", "Y", "Y", "Y", "Y"])
    elsif datatype.time?
     html += field_table(["H", "H", ":", "M", "M"])
    elsif datatype.float?
      item.format = "5.1" if item.format.blank?
      parts = item.format.split('.')
      major = parts[0].to_i
      minor = parts[1].to_i
      pattern = ["#"] * major
      pattern[major-minor-1] = "."
      html += field_table(pattern)
    elsif datatype.integer?
      count = item.format.to_i
      html += field_table(["#"]*count)
    elsif datatype.string?
      length = item.format.scan /\w/
      html += field_table([" "]*5 + ["S"] + length + [""]*5)
    elsif datatype.boolean?
      html += '<input type="checkbox">'
    else
      html += field_table(["?", "?", "?"])
    end
    html += '</td>'
  end

  # Format a field
  def field_table(cell_content)
    html = "<table class=\"crf-input-field\"><tr>"
    cell_content.each do |cell|
      html += "<td>#{cell}</td>"
    end
    html += "</tr></table>"
  end

  def terminology_cell
    html = '<td>'
    self.has_coded_value_objects.sort_by {|x| x.ordinal}.each do |cv|
      tc = Thesaurus::UnmanagedConcept.find(cv.reference)
      if cv.enabled
        html += "<p><input type=\"radio\" name=\"#{tc.identifier}\" value=\"#{tc.identifier}\"></input>#{tc.label}</p>"
      end
    end
    html += '</td>'
  end

  def coded_values_to_hash(coded_values)
    results = []
    coded_values.sort_by {|x| x.ordinal}.each do |cv|
      ref = cv.to_h
      ref[:reference] = Thesaurus::UnmanagedConcept.find(cv.reference).to_h
      parent = Thesaurus::ManagedConcept.find_with_properties(cv.context)
      ref[:context] = {id: parent.id, uri: parent.uri.to_s, identifier: parent.has_identifier.identifier, notation: parent.notation, semantic_version: parent.has_identifier.semantic_version}
      results << ref
    end
    results
  end

  # Full data
  #
  # @return [Hash] Return the data of the whole node
  def full_data
    item = self.to_h
    item[:has_coded_value] = get_cv_ref(self.has_coded_value_objects) unless item[:has_coded_value].nil?
    item[:has_property] = self.has_property_objects.to_h unless item[:has_property].nil?
    item[:has_common_item] = get_ci_ref(self.has_common_item_objects) unless item[:has_common_item].nil?
    item
  end

  def get_cv_ref(coded_values)
    results = []
    coded_values.sort_by {|x| x.ordinal}.each do |cv|
      ref = cv.to_h
      ref[:reference] = Thesaurus::UnmanagedConcept.find(cv.reference).to_h
      results << ref
    end
    results
  end

  def get_ci_ref(common_items)
    results = []
    common_items.sort_by {|x| x.ordinal}.each do |ci|
      results << ci.full_data
    end
    results
  end

  # Next Ordinal. Get the next ordinal for a managed item collection
  #
  # @param [String] name the name of the property holding the collection
  # @return [Integer] the next ordinal
  def next_ordinal(name)
    predicate = self.properties.property(name).predicate
    query_string = %Q{
      SELECT (MAX(?ordinal) AS ?max)
      {
        #{self.uri.to_ref} #{predicate.to_ref} ?s .
        ?s bo:ordinal ?ordinal
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bo])
    return 1 if query_results.empty?
    query_results.by_object(:max).first.to_i + 1
  end

end