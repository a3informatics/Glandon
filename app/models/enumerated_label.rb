class EnumeratedLabel < IsoConcept
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  #def initialize(triples=nil, id=nil)
  #  if triples.nil?
  #    super
  #  else
  #    super(triples, id)
  #  end
  #end

  # Find All entries for a given type within a given schema within a given instance namespace
  #
  # @param rdf_type [string] The rdf_type (fragment)
  # @param schema_prefix [string] The schema prefix
  # @param instance_namesapce [string] The instance namespace
  # @result [array] Array of objects.
  def self.all(rdf_type, schema_prefix, instance_namespace)
    results = Array.new
    query = UriManagement.buildPrefix(schema_prefix, []) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdf_type + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  FILTER(STRSTARTS(STR(?a), \"" + instance_namespace + "\")) \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('b', false, node)
      if uri != "" && label != ""
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdf_type = rdf_type
        object.label = label
        results << object
      end
    end
    return results
  end

  def self.find_from_triples(triples, id)
    object = new(triples, id)
    object.triples = ""
    return object
  end

end
