require 'rails_helper'

describe Element do
  
  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/element"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "create" do
    actual = Element.create(label: "XXX")
    expect(actual.label).to eq("XXX")
    expect(actual.in_arm).to eq(nil)
    expect(actual.in_epoch).to eq(nil)
    actual = Element.find(actual.uri)
    expect(actual.label).to eq("XXX")
    expect(actual.in_arm).to eq(nil)
    expect(actual.in_epoch).to eq(nil)
    check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
  end

  it "simple update" do
    actual = Element.create(label: "XXX")
    actual = Element.find(actual.uri)
    actual.label = "New label"
    actual.save
    actual = Element.find(actual.uri)
    check_file_actual_expected(actual.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
    actual.label = "Really new label"
    actual.save
    expect(actual.label).to eq("Really new label")
    check_file_actual_expected(actual.to_h, sub_dir, "update_expected_2.yaml", equate_method: :hash_equal)
  end

end