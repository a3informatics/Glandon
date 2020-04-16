require 'rails_helper'

describe "TripleStore" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/triple_store"
  end

  describe "find" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
      load_data_file_into_triple_store("hackathon_thesaurus.ttl")
      load_data_file_into_triple_store("hackathon_tas.ttl")
      load_data_file_into_triple_store("hackathon_indications.ttl")
      load_data_file_into_triple_store("hackathon_endpoints.ttl")
      load_data_file_into_triple_store("hackathon_parameters.ttl")
      load_data_file_into_triple_store("hackathon_protocols.ttl")
      load_data_file_into_triple_store("hackathon_bc_instances.ttl")
      load_data_file_into_triple_store("hackathon_bc_templates.ttl")
    end

    it "find" do
      actual = TripleStore.find(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR").to_id)
      check_file_actual_expected(actual, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal, write_file: true)
      actual = TripleStore.find(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      check_file_actual_expected(actual, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end