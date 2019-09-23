require 'rails_helper'

describe "Tokens", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include BrowserSessionHelpers
  include WaitForAjaxHelper

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessForm.ttl", "BusinessDomain.ttl", "CDISCBiomedicalConcept.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl", "form_crf_test_1.ttl",
      "sdtm_user_domain_ds.ttl", "sdtm_model_and_ig.ttl"]
    load_files(schema_files, data_files)
    # clear_triple_store
    # load_schema_file_into_triple_store("ISO11179Types.ttl")
    # load_schema_file_into_triple_store("ISO11179Identification.ttl")
    # load_schema_file_into_triple_store("ISO11179Registration.ttl")
    # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    # load_schema_file_into_triple_store("ISO25964.ttl")
    # load_schema_file_into_triple_store("BusinessOperational.ttl")
    # load_schema_file_into_triple_store("BusinessForm.ttl")
    # load_schema_file_into_triple_store("BusinessDomain.ttl")
    # load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    # load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    # load_test_file_into_triple_store("iso_namespace_real.ttl")
    #
    # load_test_file_into_triple_store("thesaurus.ttl")
    # load_test_file_into_triple_store("form_crf_test_1.ttl")
    # load_test_file_into_triple_store("sdtm_user_domain_ds.ttl")
    # load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    Token.delete_all
    ua_add_user email: "token_user_1@example.com", role: :curator
    ua_add_user email: "token_user_2@example.com", role: :curator
  end

  after :all do
    ua_remove_user "token_user_1@example.com"
    ua_remove_user "token_user_2@example.com"
  end

  describe "Curator User", :type => :feature do

    it "locks a terminology", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_terminology
        find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: CDISC EXT'
        wait_for_ajax
        context_menu_element('history', 4, 'CDISC Extensions', :edit)
        expect(page).to have_content 'Edit:'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_terminology
        find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: CDISC EXT'
        wait_for_ajax
        context_menu_element('history', 4, 'CDISC Extensions', :edit)
        expect(page).to have_content 'The item is locked for editing by another user.'
      end

    end

    it "locks a biomedical concept"

    it "locks a form", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_forms
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: CRF TEST 1'
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'Edit:'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_forms
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: CRF TEST 1'
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'The item is locked for editing by another user.'
      end

    end

    it "locks a domain", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_sponsor_domain
        find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'History').click
        pause
        expect(page).to have_content 'History: DS Domain'
        find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'Edit:'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_sponsor_domain
        find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: DS Domain'
        find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'The item is locked for editing by another user.'
      end

    end

  end

end
