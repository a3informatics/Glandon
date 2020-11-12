require 'rails_helper'

describe CDISCLibraryAPIReader do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/cdisc_library_api_reader"
  end

  it "initialize object, success" do
    object = CDISCLibraryAPIReader.new("xxxxx")
    expect(object.engine).to_not be_nil
    expect(object.errors.count).to eq(0)
  end

  it "execute" do
    object = CDISCLibraryAPIReader.new("xxxxx")
    expect_any_instance_of(CDISCLibraryAPIReader::Engine).to receive(:process).with("xxxxx")
    object.execute({})
  end

  it "returns full path" do
    object = CDISCLibraryAPIReader.new("xxxxx")
    expect(object.full_path).to eq("CDISC API: xxxxx")
  end

end