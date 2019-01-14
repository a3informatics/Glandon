require 'rails_helper'

describe ImportFileHelpers do

  include PublicFileHelpers
  include DataHelpers
  
  def sub_dir
    return "models/concerns/import_file_helpers"
  end

  def import_full_path(filename)
    return Rails.root.join(APP_CONFIG['import_files'], filename).to_s
  end

  before :each do
    delete_all_public_test_files
  end

  after :all do
    #delete_all_public_test_files
  end

  it "saves an import error file" do
    content = {a: "xxx", b: "YYY"}
    result = ImportFileHelpers.save_errors(content, "export_2.yml")
    expect(result).to eq(public_path("test", "export_2.yml").to_s)
    result = ImportFileHelpers.read_errors(public_path("test", "export_2.yml").to_s)
    expect(result).to eq(content)
  end

  it "reads an import file, yml extension" do
    content = {a: "xxx", b: "YYY"}
    result = ImportFileHelpers.save_errors(content, "export_3.yml")
    expect(result).to eq(public_path("test", "export_3.yml").to_s)
    result = ImportFileHelpers.read_errors(public_path("test", "export_3.yml").to_s)
    expect(result).to eq(content)
  end

  it "moves a file" do
    content = {a: "xxx", b: "YYY"}
    result = ImportFileHelpers.save_errors(content, "export_1.yml")
    result = ImportFileHelpers.move(public_path("test", "export_1.yml").to_s, "export_1_moved.yml")
    result = ImportFileHelpers.read_errors(public_path("test", "export_1_moved.yml").to_s)
    expect(result).to eq(content)
  end


end