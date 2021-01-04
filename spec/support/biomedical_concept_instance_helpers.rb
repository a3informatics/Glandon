module BiomedicalConceptInstanceHelpers
  
  def create_biomedical_concept_instance(identifier, label)
    bc = BiomedicalConceptInstance.create(:identifier => identifier, :label => label)
  end

end