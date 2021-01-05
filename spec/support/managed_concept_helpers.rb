module ManagedConceptHelpers
  
  def self.create(params, standard=true)
    params[:synonyms] = [] unless params.key?(:synonyms)
    mc = Thesaurus::ManagedConcept.from_h(params.slice(:identifier, :label, :defintion, :notation))
    mc.preferred_term = Thesaurus::PreferredTerm.where_only_or_create(params[:preferred_term])
    params[:synonyms].each {|x| mc.synonym << Thesaurus::Synonym.where_only_or_create(x)}
    mc.set_initial(params[:identifier])
    sparql = Sparql::Update.new
    sparql.default_namespace(mc.uri.namespace)
    mc.to_sparql(sparql, true)
    sparql.create
    mc = Thesaurus::ManagedConcept.find_minimum(mc.uri)
    IsoManagedHelpers.make_item_standard(mc) if standard
    Thesaurus::ManagedConcept.find_full(mc.uri)
  end

  def self.add_child(parent, params)
    params[:synonyms] = [] unless params.key?(:synonyms)
    child = Thesaurus::UnmanagedConcept.from_h(params.slice(:identifier, :label, :defintion, :notation))
    child.preferred_term = Thesaurus::PreferredTerm.where_only_or_create(params[:preferred_term])
    params[:synonyms].each {|x| child.synonym << Thesaurus::Synonym.where_only_or_create(x)}
    child.uri = child.create_uri(parent.uri)
    child.save
    parent.add_link(:narrower, child.uri)
    Thesaurus::ManagedConcept.find_full(child.uri)
  end

end