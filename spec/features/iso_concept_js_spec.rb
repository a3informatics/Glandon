require 'rails_helper'

describe "ISO Concept JS", :type => :feature do

  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BC.ttl", "form_example_vs_baseline.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..42)
    clear_iso_concept_object
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "Curator User", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end



end
