require 'rails_helper'

describe "S8 General", :type => :feature do
  
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  before :each do
    ua_curator_login
  end

  describe "Curator User", :type => :feature do

    it "check page title", js: true do
      expect(page.title).to have_content "Glandon MDR"
      expect(page).to have_content "Glandon MDR (v#{Version::VERSION})"
    end

  end

end