require 'rails_helper'

describe "Therapeutic Area Data" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/therapeutic_area/data"
  end

  before :all do
    data_files = ["indications.ttl", "hackathon_thesaurus.ttl"]
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
  end

  after :each do
    delete_all_public_test_files
  end

  describe "Basic Definitons" do

    it "Therapeutic Areas" do

      # TAs
      i_1 = Indication.where(label: "Alzheimer's Disease")
      ta_1 = TherapeuticArea.new(label: "Nervous system disorders", includes_indication: [i_1.first.uri])
      ta_1.set_initial("TA NSD")
      i_2 = Indication.where(label: "Diabetes Mellitus")
      ta_2 = TherapeuticArea.new(label: "Metabolic", includes_indication: [i_2.first.uri])
      ta_2.set_initial("TA M")
      i_3 = Indication.where(label: "Rheumatoid Arthritis")
      ta_3 = TherapeuticArea.new(label: "Inflammation", includes_indication: [i_3.first.uri])
      ta_3.set_initial("TA I")
      i_4 = Indication.where(label: "Influenza")
      ta_4 = TherapeuticArea.new(label: "Vaccines", includes_indication: [i_4.first.uri])
      ta_4.set_initial("TA V")

      # Generate
      sparql = Sparql::Update.new
      sparql.default_namespace(ta_1.uri.namespace)
      ta_1.to_sparql(sparql, true)
      ta_2.to_sparql(sparql, true)
      ta_3.to_sparql(sparql, true)
      ta_4.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "tas.ttl")
    end

  end

end