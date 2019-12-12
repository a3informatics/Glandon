require 'rails_helper'

describe "Thesauri Release Select", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  describe "The Curator User can", :type => :feature, js:true do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "CDISCTerm.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..46)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "10")
      NameValue.create(name: "thesaurus_child_identifier", value: "999")
      Thesaurus.create({:identifier => "TEST_RS", :label => "Test RS Label"})
      Token.delete_all
      ua_create
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

    it "display the release select page, initial state"
    it "select a CDISC version"
    it "switch tabs"
    it "select CLs for the thesaurus, single or bulk"
    it "deselect CLs from the thesaurus, single or bulk"
    it "exclude CLs from the thesaurus, single or bulk"
    it "change the CDISC version, clears selection"
    it "initializes saved thesauri selection state correctly"
    it "edit lock, extend"
    it "expires edit lock, prevents additional changes"
    it "clears token when leaving page"

  end

end
