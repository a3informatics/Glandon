require 'rails_helper'

describe "CanonicalReference" do

    include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/canonical_reference"
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
      item = CanonicalReference.new(definition: "xxxx", bridg: "xxx.xxx.xxx")
      item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/path#a"))
      result = item.valid?
      expect(result).to be(true)
      item = CanonicalReference.new(bridg: "xxx.xxx.xxx")
      item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/path#a"))
      result = item.valid?
      expect(result).to be(false)
      expect(item.errors.full_messages.to_sentence).to eq("Definition can't be blank")
      item = CanonicalReference.new(definition: "ddddd")
      item.uri = item.create_uri(Uri.new(uri: "http://www.example.com/path#a"))
      result = item.valid?
      expect(result).to be(false)
      expect(item.errors.full_messages.to_sentence).to eq("Bridg can't be blank")
    end

  end

end