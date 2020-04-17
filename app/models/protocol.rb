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
    results = {}
    query_string = %Q{
      SELECT DISTINCT ?e ?el ?a ?al ?ele ?elel WHERE
      {
        #{self.uri.to_ref} pr:specifiesEpoch ?e .
        ?e pr:ordinal ?eo .
        ?e isoC:label ?el .
        ?e ^pr:inEpoch ?ele .         
        ?ele isoC:label ?elel .
        ?ele pr:inArm ?a .
        ?a isoC:label ?al .
        ?a pr:ordinal ?ao .
      } ORDER BY ?eo ?ao
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bo, :isoC, :pr])
    triples = query_results.by_object_set([:e, :el, :a, :al, :ele, :elel])
    return [] if triples.empty?
    triples.each do |entry|
      uri_s = entry[:e].to_s
      results[uri_s] = {label: entry[:el], id: entry[:e].to_id, arms: []} if !results.key?(uri_s)
      results[uri_s][:arms] << {label: entry[:al], id: entry[:a].to_id, element: {label: entry[:elel], id: entry[:ele].to_id}}
    end
    results.map{|k,v| v}
  end 

  def from_template(template)
    items = {}
    self.specifies_epoch = []
    self.specifies_arm = []
    elements = template.elements
    query_string = %Q{
      SELECT DISTINCT ?el ?ell ?a ?e WHERE
      {
        VALUES ?el { #{elements.map{|x| x.to_ref}.join(" ")} }
        ?el pr:inArm ?a .
        ?el pr:inEpoch ?e .
        ?el isoC:label ?ell
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :pr])
    triples = query_results.by_object_set([:el, :e, :a])
    triples.each do |entry| 
      new_arm = clone_if(Arm.find(entry[:a]), items)
      new_epoch = clone_if(Epoch.find(entry[:e]), items)
      new_el = Element.new(label: entry[:ell], in_epoch: new_epoch.uri, in_arm: new_arm.uri)
      new_el.uri = new_el.create_uri(new_el.class.base_uri)
      new_el.save
      self.specifies_epoch_push(new_epoch.uri)
      self.specifies_arm_push(new_arm.uri)
    end
    self.save
  end       

private

  def clone_if(item, collection)
    return collection[item.uri.to_s] if collection.key?(item.uri.to_s)
    new_item = item.clone
    new_item.uri = new_item.create_uri(new_item.class.base_uri)
    new_item.save
    collection[item.uri.to_s] = new_item
    new_item
  end
    
end
