require 'rails_helper'

describe Upload do
	
	include PublicFileHelpers

  before :all do
    delete_all_public_files
  end

  def files_list(ext="*.*")
    Dir.glob(Rails.root.join(APP_CONFIG['upload_files']) + ext).sort!
  end

  def file_path(filename)
    Rails.root.join(APP_CONFIG['upload_files'], filename).to_s
  end

	it "delete multiple files" do
    filename = PublicFile.save("test", "PublicFile1.txt", "Contents of the file 1")
    filename = PublicFile.save("test", "PublicFile2.xml", "Contents of the file 2")
    filename = PublicFile.save("test", "PublicFile3.xml", "Contents of the file 3")
    item = Upload.new
    item.delete_multiple({files: ["PublicFile1.txt", "PublicFile3.xml"]})
    expect(item.errors.count).to eq(0)
    expect(files_list).to eq([file_path("PublicFile2.xml")])
  end

  it "delete all files" do
    filename = PublicFile.save("test", "PublicFile1.txt", "Contents of the file 2")
    filename = PublicFile.save("test", "PublicFile2.xml", "Contents of the file 2")
    filename = PublicFile.save("test", "PublicFile3.xml", "Contents of the file 3")
    item = Upload.new
    item.delete_all
    expect(files_list).to eq([])
  end

end