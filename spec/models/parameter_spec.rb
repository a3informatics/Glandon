require 'rails_helper'

describe "Parameter" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      uri = Uri.new(uri: "http://www.assero.co.uk/Thesaurus#BiomedicalConceptInstance")
      item = Parameter.create(label: "XXX", parameter_rdf_type: uri)
      actual = Parameter.find(item.uri)
      expect(actual.parameter_rdf_type).to eq(uri)
    end

  end

end