require 'rails_helper'

describe "SDTM Model Domains", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers

  describe "Basic Operations", :type => :feature do

    before :all do
      data_files = ["iso_registration_authority_real.ttl", "iso_namespace_real.ttl", "BCT.ttl", "BC.ttl", "sdtm_model_and_ig.ttl"]
      load_files(schema_files, data_files)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    it "allows the show page to be viewed", js:true do
      click_navbar_ig_domain
      expect(page).to have_content 'History: CDISC SDTM Implementation Guide'
      find(:xpath, "//tr[contains(.,'SDTM Implementation Guide 2013-11-26')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: SDTM Implementation Guide 2013-11-26 SDTM IG (V3.2.0, 3, Standard)'
      find(:xpath, "//tr[contains(.,'SDTM IG DS')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Disposition SDTM IG DS (V3.2.0, 3, Standard)'
    end

    it "*** SDTM IMPORT SEMANTIC VERSION ***"

  end

end
