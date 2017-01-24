require 'rails_helper'

describe "Tokens", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include BrowserSessionHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("thesaurus.ttl")
    load_test_file_into_triple_store("form_crf_test_1.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_ds.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    Token.delete_all
    user1 = User.create :email => "token_user_1@example.com", :password => "12345678" 
    user1.add_role :curator
    user2 = User.create :email => "token_user_2@example.com", :password => "12345678" 
    user2.add_role :curator
  end

  after :all do
    user = User.where(:email => "token_user_1@example.com").first
    user.destroy
    user = User.where(:email => "token_user_2@example.com").first
    user.destroy
  end

  describe "Curator User", :type => :feature do

    it "locks a terminology" do

      in_browser(:one) do
        visit '/users/sign_in'
        fill_in 'Email', with: 'token_user_1@example.com'
        fill_in 'Password', with: '12345678'
        click_button 'Log in'
        expect(page).to have_content 'Signed in successfully'  
        visit '/thesauri'
        find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: CDISC EXT'
        find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'Edit:'
      end

      in_browser(:two) do
        visit '/users/sign_in'
        fill_in 'Email', with: 'token_user_2@example.com'
        fill_in 'Password', with: '12345678'
        click_button 'Log in'
        expect(page).to have_content 'Signed in successfully'  
        visit '/thesauri'
        find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: CDISC EXT'
        find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'The item is locked for editing by another user.'
      end

    end

    it "locks a biomedical concept"

    it "locks a form" do

      in_browser(:one) do
        visit '/users/sign_in'
        fill_in 'Email', with: 'token_user_1@example.com'
        fill_in 'Password', with: '12345678'
        click_button 'Log in'
        expect(page).to have_content 'Signed in successfully'  
        visit '/forms'
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: CRF TEST 1'
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'Edit:'
      end

      in_browser(:two) do
        visit '/users/sign_in'
        fill_in 'Email', with: 'token_user_2@example.com'
        fill_in 'Password', with: '12345678'
        click_button 'Log in'
        expect(page).to have_content 'Signed in successfully'  
        visit '/forms'
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: CRF TEST 1'
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'The item is locked for editing by another user.'
      end

    end

    it "locks a domain" do

      in_browser(:one) do
        visit '/users/sign_in'
        fill_in 'Email', with: 'token_user_1@example.com'
        fill_in 'Password', with: '12345678'
        click_button 'Log in'
        expect(page).to have_content 'Signed in successfully'  
        visit '/sdtm_user_domains'
        find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: DS Domain'
        find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'Edit:'
      end

      in_browser(:two) do
        visit '/users/sign_in'
        fill_in 'Email', with: 'token_user_2@example.com'
        fill_in 'Password', with: '12345678'
        click_button 'Log in'
        expect(page).to have_content 'Signed in successfully'  
        visit '/sdtm_user_domains'
        find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'History').click
        expect(page).to have_content 'History: DS Domain'
        find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'Edit').click
        expect(page).to have_content 'The item is locked for editing by another user.'
      end

    end

  end

end