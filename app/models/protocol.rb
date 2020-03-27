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
  object_property :specifies_arm, cardinality: :many, model_class: "Arm"
  object_property :specifies_epoch, cardinality: :many, model_class: "Epoch"

  validates_with Validator::Field, attribute: :acronym, method: :valid_label?
  validates_with Validator::Field, attribute: :title, method: :valid_label?
  validates_with Validator::Field, attribute: :short_title, method: :valid_label?

  validates :title, presence: true

  def name_value
    uri = self.uri.to_ref
    query_string = %Q{
      SELECT DISTINCT ?a ?t ?st ?stp ?stt ?im ?m ?i ?ta WHERE
      {
        #{uri} pr:title ?t .
        OPTIONAL { #{uri} pr:acronym ?a }
        OPTIONAL { #{uri} pr:short_title ?st }
        #{uri} pr:studyPhase/bo:reference/isoC:label ?stp .
        #{uri} pr:studyType/bo:reference/isoC:label ?stt .
        #{uri} pr:interventionModel/bo:reference/isoC:label ?im .
        #{uri} pr:masking/bo:reference/isoC:label ?m .
        #{uri} pr:forIndication/isoC:label ?i .
        OPTIONAL { #{uri} pr:inTA/isoC:label ?ta }
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bo, :isoC, :pr])
    triples = query_results.by_object_set([:a, :t, :st, :stp, :stt, :im, :m, :i, :ta])
    return [] if triples.empty?
    entry = triples.first
    result = 
    [
      {name: "Acronym", value: entry[:a]},
      {name: "Title", value: entry[:t]}, 
      {name: "Short Title", value: entry[:st]}, 
      {name: "Study Phase", value: entry[:stp]}, 
      {name: "Study Type", value: entry[:stt]}, 
      {name: "Intervention", value: entry[:im]}, 
      {name: "Masking", value: entry[:m]}, 
      {name: "Indication", value: entry[:i]}, 
      {name: "Therapeutic Area", value: entry[:ta]}
    ]
  end

  # Design. Get the design for the protocol
  #
  # @return [Array] Array of epochs and the associated arms and elemnts 
  def design
    uri = self.uri.to_ref
    query_string = %Q{
      SELECT DISTINCT ?a ?e ?el WHERE
      {
        #{uri} pr:specifiesEpoch ?e .
        ?e ^pr:inEpoch ?el .
        ?el pr:inArm ?a
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bo, :isoC, :pr])
    triples = query_results.by_object_set([:a, :e, :el])
byebug
    return [] if triples.empty?
  end    

end
