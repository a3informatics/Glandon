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
  include Form::CRF
  include Form::PDFReport

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

  # To XML
  #
  # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # @param [Nokogiri::Node] form_def the ODM FormDef node
  # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # @return [void]
  def to_xml(metadata_version, form_def, item_group_def)
    item_group_def.add_item_ref("#{self.id}", "#{self.ordinal}", "No", "", "", "", "", "")
  end

  # Delete. Delete the object. Clone if there are multiple parents.
  #
  # @param [Object] parent_object the parent object
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Object] the parent object, either new or the cloned new object with updates
  def delete(parent, managed_ancestor)
    if multiple_managed_ancestors?
      parent = delete_with_clone(parent, managed_ancestor)
      parent.reset_ordinals
    else
      delete_node(parent)
    end
    normal_group = Form::Group::Normal.find_full(parent.uri)
    normal_group = normal_group.full_data
  end

  # Move Up With Clone
  #
  # @param [Object] child the object to be moved
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Void] no return
  def move_up_with_clone(child, managed_ancestor)
    if multiple_managed_ancestors?
      parent_and_child = self.replicate_siblings_with_clone(child, managed_ancestor)
      parent_and_child.first.move_up(parent_and_child.second)
    else
      move_up(child)
    end
  end

  # Move Down With Clone
  #
  # @param [Object] child the object to be moved
  # @param [Object] managed_ancestor the managed ancestor object
  # @return [Void] no return
  def move_down_with_clone(child, managed_ancestor)
    if multiple_managed_ancestors?
      parent_and_child = self.replicate_siblings_with_clone(child, managed_ancestor)
      parent_and_child.first.move_down(parent_and_child.second)
    else
      move_down(child)
    end
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

private

  def to_xml_length(datatype, format)
    if datatype == BaseDatatype::C_STRING
      format = "20" if format.blank? # @todo make sure this is set in BCs
      return format
    elsif datatype == BaseDatatype::C_INTEGER || datatype == BaseDatatype::C_POSITIVE_INTEGER
      format = "3" if format.blank? # @todo make sure this is set in BCs
      return format
    elsif datatype == BaseDatatype::C_FLOAT
      format = "5.1" if format.blank? # @todo make sure this is set in BCs
      parts = format.split('.')
      length = (parts[0].to_i) - 1
      return length
    else
      return ""
    end
  end

  def to_xml_significant_digits(datatype, format)
    if datatype == BaseDatatype::C_FLOAT
      format = "5.1" if format.blank? # @todo make sure this is set in BCs
      parts = format.split('.')
      digits = (parts[1].to_i)
      return digits
    else
      return ""
    end
  end

  # Delete the node
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

end
