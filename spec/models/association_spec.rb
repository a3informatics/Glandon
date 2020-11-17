require 'rails_helper'

describe "Association" do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/association"
  end

  describe "Basic tests" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      #
    end

    it "valid" do
      item = Association.new()
      item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/path#a"))
      result = item.valid?
      expect(result).to be(true)
    end

    it "not valid" do
      item = Association.new()
      result = item.valid?
      expect(result).to be(false)
      expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank")
    end

  end

end