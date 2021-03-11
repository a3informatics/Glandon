require 'rails_helper'

describe "B - Parameters" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/import/data/sanofi"
  end

  before :all do
    IsoHelpers.clear_cache
    clear_triple_store    
    load_local_file_into_triple_store(sub_dir, "sanofi_protocol_base_2.nq.gz")
    test_query # Make sure any loading has finished.
    load_schema_file_into_triple_store("protocol.ttl")
    load_schema_file_into_triple_store("enumerated.ttl")
    load_schema
  end

  after :all do
    #
  end

  before :each do
    #
  end

  after :each do
    delete_all_public_test_files
  end

  describe "Parameters" do

    it "Parameters" do
      uri = Uri.new(uri: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptInstance")
      p_1 = Parameter.new(label: "BC", parameter_rdf_type: uri)
      p_1.uri = p_1.create_uri(p_1.class.base_uri)
      uri = Uri.new(uri: "http://www.assero.co.uk/Protocol#Intervention")
      p_2 = Parameter.new(label: "Intervention", parameter_rdf_type: uri)
      p_2.uri = p_2.create_uri(p_2.class.base_uri)
      uri = Uri.new(uri: "http://www.assero.co.uk/Protocol#TimepointOffset")
      p_3 = Parameter.new(label: "Timepoint", parameter_rdf_type: uri)
      p_3.uri = p_3.create_uri(p_3.class.base_uri)
      uri = Uri.new(uri: "http://www.assero.co.uk/Protocol#Assessment")
      p_4 = Parameter.new(label: "Assessment", parameter_rdf_type: uri)
      p_4.uri = p_4.create_uri(p_4.class.base_uri)
      sparql = Sparql::Update.new
      sparql.default_namespace(p_1.uri.namespace)
      p_1.to_sparql(sparql, true)
      p_2.to_sparql(sparql, true)
      p_3.to_sparql(sparql, true)
      p_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "b_parameters.ttl")
    end

  end

end

