require 'rails_helper'

describe Endpoint do
  
  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/endpoint"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "create" do
    actual = Endpoint.create(identifier: "XXX")
    expect(actual.scoped_identifier).to eq("XXX")
    expect(actual.version).to eq(1)
    expect(actual.semantic_version).to eq("0.1.0")
    actual = Endpoint.find_minimum(actual.uri)
    expect(actual.scoped_identifier).to eq("XXX")
    expect(actual.version).to eq(1)
    expect(actual.semantic_version).to eq("0.1.0")
    check_dates(actual, sub_dir, "create_expected_1.yaml", :creation_date, :last_change_date)
    check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
  end

end