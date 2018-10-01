require 'rails_helper'

describe ExportFileHelpers do

  include PublicFileHelpers
  include DataHelpers

  
  def sub_dir
    return "models/concerns/export_file_helpers"
  end

  def export_set_path(filename)
    return Rails.root.join(Rails.configuration.general['define_files'], sub_dir)
  end

  before :each do
    delete_all_public_test_files
  end

  after :all do
    delete_all_public_test_files
  end

  it "saves an export file" do
    content = "<A><B></B></A>"
    ExportFileHelpers.save(content, "export_1.txt")
    result = read_public_text_file("test", "export_1.txt")
    expect(result).to eq(content)
  end

end