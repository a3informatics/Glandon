class IsoConcept::ExtendedProperty

  C_CLASS_NAME = "IsoConcept::ExtendedProperty"
  
  attr_reader :identifier, :datatype, :label, :definition, :uri

  # Initialize method
  #
  # @param Args [hash] {:identifier, :datatype, :value, :label, :defintion}
  # @return null
  def initialize(args)    
    @identifier = args[:identifier]
    @datatype = args[:datatype]
    @label = args[:label]
    @definition = args[:definition]
  end

  # To JSON
  #
  # @return [hash] JSON representation of the value
  def to_json
    return { identifier: @identifier, datatype: @datatype, label: @label, definition: @definition }
  end

  # To SPARQL
  #
  # @param sparql [object] The SPARQL object
  # @param parent_uri [uri] The uri of the parent 
  # @param parent_class_uri [uri] The uri of the parent class 
  # @return [uri] The subject uri
  def to_sparql_v2(sparql, parent_uri, parent_class_uri)
    @uri = UriV2.new({ :namespace => parent_uri.namespace, :id => "#{@identifier}" })
    subject = {:namespace => @uri.namespace, :id => @uri.id}
    sparql.triple(subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_OWL, :id => "DatatypeProperty"})
    sparql.triple(subject, {:prefix => UriManagement::C_RDFS, :id => "subPropertyOf"}, {:prefix => UriManagement::C_ISO_C, :id => "extensionProperty"})
    sparql.triple(subject, {:prefix => UriManagement::C_RDFS, :id => "domain"}, {:uri => parent_class_uri})
    sparql.triple(subject, {:prefix => UriManagement::C_RDFS, :id => "label"}, {:literal => "#{@label}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_RDFS, :id => "range"}, {:prefix => "xsd", :id => BaseDatatype.to_xsd(@datatype)})
    sparql.triple(subject, {:prefix => UriManagement::C_SKOS, :id => "definition"}, {:literal => "#{@definition}", :primitive_type => "string"})
    return @uri
  end

end