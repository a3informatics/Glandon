require 'rails_helper'

describe Timestamp do
	
	it "allows for a file to be moved to the upload directory" do
    source_path = Rails.root.join "db/load/test/upload.txt"
    target_path = Rails.root.join "public/upload/upload.txt"
    File.delete(target_path) if File.exist?(target_path)
    file_obj = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, 'db/load/test/upload.txt')))
    file = Hash.new
    file['datafile'] = file_obj
    Upload.save(file)
    expect(File.exist?(target_path)).to eq(true)
	end

end