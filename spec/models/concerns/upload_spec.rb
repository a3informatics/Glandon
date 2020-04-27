require 'rails_helper'

describe Timestamp do
	
  it "allows for a file to be moved to the upload directory" do
    source_path = Rails.root.join "spec/fixtures/files/features/upload.txt"
    target_path = Rails.root.join "#{APP_CONFIG['upload_files']}/upload.txt"
    File.delete(target_path) if File.exist?(target_path)
    file_obj = Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, 'spec/fixtures/files/features/upload.txt')))
    file = Hash.new
    file['datafile'] = file_obj
    Upload.save(file)
    expect(File.exist?(target_path)).to eq(true)
  end

end