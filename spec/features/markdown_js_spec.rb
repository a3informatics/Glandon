require 'rails_helper'

describe "Markdown", :type => :feature do

  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
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

  describe "valid user", :type => :feature, js: true do

    it "allows markdown" do
      click_navbar_ma
      expect(page).to have_content 'Raw Markdown:'
      expect(page).to have_content 'Processed Markdown:'
      fill_in "raw_markdown", with: "Hello world I am *here*"
      click_button "Preview"
      div = page.find("#generic_markdown")
      expect(div.text(:all)).to eq("Hello world I am here")
      fill_in "raw_markdown", with: "£±£±"
      click_button "Validate"
      expect(page).to have_content 'Please enter valid markdown.'
    end

  end

end
