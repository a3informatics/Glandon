require 'rails_helper'

describe PublicFile do
	
  it "save a file" do
    PublicFile.save("Test", "PublicFile1", "Contents of the file")
    public_dir = Rails.root.join("public", "Test")
    read_file = File.join(public_dir, "PublicFile1")
    data = File.read(read_file)
    expect(data).to eq("Contents of the file")
  end

end