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
    expect(filename).to eq("/Users/daveih/Documents/rails/Glandon/public/test/PublicFile1.txt")
  end

end