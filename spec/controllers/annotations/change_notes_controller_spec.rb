require 'rails_helper'

describe Annotations::ChangeNotesController, type: :controller do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers

  describe "change notes" do

    before :all do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "update change note"

    it "destroy change note"

  end

end
