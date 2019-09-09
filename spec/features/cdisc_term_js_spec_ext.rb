require 'rails_helper'

describe "CDISC Term", :type => :feature do
  
  include DataHelpers
  include PublicFileHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper

  def wait_for_ajax_v_long
    wait_for_ajax(120)
  end

  describe "CDISC Terminology", :type => :feature do
  
    before :all do
      clear_triple_store
      ua_create
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCTerm.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_cdisc_term_versions(1..46)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      delete_all_public_test_files
    end

    before :each do
      ua_curator_login
    end

    after :all do
      ua_destroy
    end

    it "allows the CDISC Terminology code list to be extended with one from another code list  (REQ-MDR-CT-031)", js:true do
      
    end


    it "allows the CDISC Terminology code list to be extended with one from another CDISC code list  (REQ-MDR-CT-031)", js:true do
      
    end


  end

end