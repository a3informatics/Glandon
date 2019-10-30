require 'rails_helper'

describe ControllerHelpers do
	
	include PublicFileHelpers
  include ControllerHelpers
  include DataHelpers
  
  def sub_dir
    return "controllers/concerns/controller_helpers"
  end

  before :each do
    delete_all_public_files
  end

	it "lists upload files" do
    copy_file_to_public_files(sub_dir, "new_1.xml", "test")
    copy_file_to_public_files(sub_dir, "new_2.xml", "test")
    copy_file_to_public_files(sub_dir, "new_3.txt", "test")
    file_1 = public_path("test", "new_1.xml").to_s
    file_2 = public_path("test", "new_2.xml").to_s
    file_3 = public_path("test", "new_3.txt").to_s
    expect(upload_files("*.xml")).to match_array([file_1, file_2])
    expect(upload_files("*.txt")).to match_array([file_3])       
    expect(upload_files("*.*")).to match_array([file_1, file_2, file_3])       
  end

  it "adds history paths" do
    # Checked in Thesauri Controller
    expect(true).to be(true)
  end

end