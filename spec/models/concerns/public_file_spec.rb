require 'rails_helper'

describe PublicFile do
	
	 include PublicFileHelpers

   before :all do
    delete_all_public_files
  end

	it "saves a file" do
    filename = PublicFile.save("test", "PublicFile1.txt", "Contents of the file")
    public_dir = Rails.root.join("public", "test")
    read_file = File.join(public_dir, "PublicFile1.txt")
    data = File.read(read_file)
    expect(data).to eq("Contents of the file")
    path = Rails.root.join("public", "test", "PublicFile1.txt")
    expect(filename).to eq(path.to_s)
  end

  it "reads a file" do
    filename = PublicFile.save("test", "PublicFile2.txt", "Contents of the file 2")
    data = PublicFile.read(filename)
    expect(data).to eq("Contents of the file 2")
    path = Rails.root.join("public", "test", "PublicFile2.txt")
    expect(filename).to eq(path.to_s)
  end

end