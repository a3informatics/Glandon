class Form::Item < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Item",
            uri_suffix: "I",
            uri_property: :ordinal


  data_property :ordinal, default: 1
  data_property :note
  data_property :completion
  data_property :optional, default: false

  validates_with Validator::Field, attribute: :ordinal, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :note, method: :valid_markdown?
  validates_with Validator::Field, attribute: :completion, method: :valid_markdown?
  validates :optional, inclusion: { in: [ true, false ] }

  Form::Item::Placeholder.new
  Form::Item::Question.new
  Form::Item::BcProperty.new
  Form::Item::Mapping.new
  Form::Item::TextLabel.new
  Form::Item::Common.new

  def get_item
    item = self.to_h
    if !item[:has_coded_value].nil?
      if !item[:has_coded_value].empty?
        coded_value = []
        item[:has_coded_value].each do |cv|
          tc = OperationalReferenceV3::TucReference.find_children(Uri.new(uri:cv)).to_h
          parent = IsoManagedV2.find_minimum(Uri.new(uri: tc[:context][:uri]))
          tc[:context] = {id: parent.id, uri: parent.uri.to_s, identifier: parent.has_identifier.identifier, notation: parent.notation, semantic_version: parent.has_identifier.semantic_version}
          coded_value << tc
        end
          item[:has_coded_value] = coded_value 
      end
      # if !item[:has_property].empty?
      #   property = []
      #   item[:has_property].each do |prop|
      #     tc = OperationalReferenceV3::TucReference.find_children(Uri.new(uri:prop)).to_h
      #     bc = BiomedicalConceptInstance.find_minimum(Uri.new(uri: tc[:reference]))
      #     property << bc.to_h
      #   end
      #     item[:has_property] = property 
      # end
    end
    return item
  end

  # # Thesaurus Concepts
  # # A null method for those classes who dont need to return TCs.
  # #
  # # @return [object] An empty array
  # def thesaurus_concepts
  #   return Array.new
  # end

  # # BC Property
  # # A null method for those classes who dont need to return a BC property.
  # #
  # # @return [nil]
  # def bc_property
  #   return nil
  # end


  # # To XML
  # #
  # # @param [Nokogiri::Node] metadata_version the ODM MetaDataVersion node
  # # @param [Nokogiri::Node] form_def the ODM FormDef node
  # # @param [Nokogiri::Node] item_group_def the ODM ItemGroupDef node
  # # @return [void]
  # def to_xml(metadata_version, form_def, item_group_def)
  #   item_group_def.add_item_ref("#{self.id}", "#{self.ordinal}", "No", "", "", "", "", "")
  # end

private

  # def to_xml_length(datatype, format)
  #   if datatype == BaseDatatype::C_STRING
  #     format = "20" if format.blank? # @todo make sure this is set in BCs
  #     return format
  #   elsif datatype == BaseDatatype::C_INTEGER || datatype == BaseDatatype::C_POSITIVE_INTEGER
  #     format = "3" if format.blank? # @todo make sure this is set in BCs
  #     return format
  #   elsif datatype == BaseDatatype::C_FLOAT
  #     format = "5.1" if format.blank? # @todo make sure this is set in BCs
  #     parts = format.split('.')
  #     length = (parts[0].to_i) - 1
  #     return length
  #   else
  #     return ""
  #   end
  # end

  # def to_xml_significant_digits(datatype, format)
  #   if datatype == BaseDatatype::C_FLOAT
  #     format = "5.1" if format.blank? # @todo make sure this is set in BCs
  #     parts = format.split('.')
  #     digits = (parts[1].to_i)
  #     return digits
  #   else
  #     return ""
  #   end
  # end

 end