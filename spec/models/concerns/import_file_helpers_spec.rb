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

  it "saves an import file, txt extension" do
    content = "<A><B></B></A>"
    result = ImportFileHelpers.save(content, "export_1.txt")
    expect(result).to eq(public_path("test", "export_1.txt").to_s)
    result = read_public_text_file("test", "export_1.txt")
    expect(result).to eq(content)
  end

  it "saves an import file, yml extension" do
    content = {a: "xxx", b: "YYY"}
    result = ImportFileHelpers.save(content, "export_2.yml")
    expect(result).to eq(public_path("test", "export_2.yml").to_s)
    result = ImportFileHelpers.read(public_path("test", "export_2.yml").to_s)
    expect(result).to eq(content)
  end

  it "reads an import file, yml extension" do
    content = {a: "xxx", b: "YYY"}
    result = ImportFileHelpers.save(content, "export_3.yml")
    expect(result).to eq(public_path("test", "export_3.yml").to_s)
    result = ImportFileHelpers.read(public_path("test", "export_3.yml").to_s)
    expect(result).to eq(content)
  end

end