class Protocol < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Protocol",
            uri_suffix: "PR"

  data_property :acronym
  data_property :title
  data_property :short_title
  object_property :study_phase, cardinality: :one, model_class: "OperationalReferenceV3::TucReference"
  object_property :study_type, cardinality: :one, model_class: "OperationalReferenceV3::TucReference"
  object_property :intervention_model, cardinality: :one, model_class: "OperationalReferenceV3::TucReference"
  object_property :masking, cardinality: :one, model_class: "OperationalReferenceV3::TucReference"
  object_property :for_indication, cardinality: :many, model_class: "Indication"
  object_property :in_TA, cardinality: :one, model_class: "TherapeuticArea"

  validates_with Validator::Field, attribute: :acronym, method: :valid_label?
  validates_with Validator::Field, attribute: :title, method: :valid_label?
  validates_with Validator::Field, attribute: :short_title, method: :valid_label?

  validates :title, presence: true

  # # List all Protocols
  # #
  # # @return [Array] Each hash contains {id, identifier, label, scope_id, owner_short_name}
  # def self.all
  #   results = []
  #   query_string = %Q{
  #     SELECT DISTINCT ?e ?l ?i ?ns ?sn WHERE
  #     {
  #       ?e rdf:type #{self.rdf_type.to_ref} .
  #       ?e isoC:label ?l .
  #       ?e isoT:hasIdentifier ?si .
  #       ?si isoI:identifier ?i .
  #       ?si isoI:hasScope ?ns .
  #       ?ns isoI:shortName ?sn .
  #     }
  #   }
  #   query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :isoR])
  #   triples = query_results.by_object_set([:e, :i, :l, :ns, :sn])
  #   triples.each do |entry|
  #     results << {id: entry[:e], identifier: entry[:i], label: entry[:l], scope_id: entry[:ns].to_id, owner: entry[:sn]}
  #   end
  #   results
  # end

end
