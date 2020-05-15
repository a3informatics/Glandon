require 'rails_helper'

describe "Thesaurus::Ranked" do

  include DataHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/thesaurus/ranked"
  end

  describe "schema load" do

    before :all do
      load_files(schema_files, [])
    end

    it "check thesaurus schema migration one" do
      result = triple_store.subject_triples(Uri.new(uri:"http://www.assero.co.uk/Thesaurus#Subset"))
      check_file_actual_expected(result, sub_dir, "schema_expected_1.yaml", write_file: true)
    end

  end

end
