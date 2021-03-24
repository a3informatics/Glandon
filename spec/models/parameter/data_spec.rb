require 'rails_helper'

describe Parameter do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers
  include ValidationHelpers

  def sub_dir
    return "models/parameter/data"
  end

  describe "Create Parameter" do
    
    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")     
    end

    after :all do
      delete_all_public_test_files
    end

    def item_to_ttl(item)
      uri = item.has_identifier.has_scope.uri
      item.has_identifier.has_scope = uri
      uri = item.has_state.by_authority.uri
      item.has_state.by_authority = uri
      item.to_ttl
    end

    it "Parameter" do
      uri = Uri.new(uri: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptInstance")
      p_1 = Parameter.new(label: "BC", parameter_rdf_type: uri)
      p_1.uri = p_1.create_uri(p_1.class.base_uri)
      uri = Uri.new(uri: "http://www.assero.co.uk/Protocol#Intervention")
      p_2 = Parameter.new(label: "Intervention", parameter_rdf_type: uri)
      p_2.uri = p_2.create_uri(p_2.class.base_uri)
      uri = Uri.new(uri: "http://www.assero.co.uk/Protocol#TimepointOffset")
      p_3 = Parameter.new(label: "Timepoint", parameter_rdf_type: uri)
      p_3.uri = p_3.create_uri(p_3.class.base_uri)
      uri = Uri.new(uri: "http://www.assero.co.uk/BiomedicalConcept#Assessment")
      p_4 = Parameter.new(label: "Assessment", parameter_rdf_type: uri)
      p_4.uri = p_4.create_uri(p_4.class.base_uri)
      sparql = Sparql::Update.new
      sparql.default_namespace(p_1.uri.namespace)
      p_1.to_sparql(sparql, true)
      p_2.to_sparql(sparql, true)
      p_3.to_sparql(sparql, true)
      p_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "parameter.ttl")
    end
  
  end

end