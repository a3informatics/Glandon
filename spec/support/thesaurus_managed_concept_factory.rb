module ThesaurusManagedConceptFactory
  
  def create_managed_concept(label)
    item = Thesaurus::ManagedConcept.create
    item.label = label
    item.save
    Thesaurus::ManagedConcept.find_minimum(item.uri)
  end

end