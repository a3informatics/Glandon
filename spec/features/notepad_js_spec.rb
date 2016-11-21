require 'rails_helper'

describe "Notepad", :type => :feature do
  
  include PauseHelpers

  before :all do
    @user = User.create :email => "curator@example.com", :password => "12345678" 
    @user.add_role :curator
    Notepad.create :uri_id => "ID1", :uri_ns => "http://www.example/com/term", :identifier => "A1", :useful_1 => "NOT1", :useful_2 => "Label1", :user_id => @user.id, :note_type => 0
    Notepad.create :uri_id => "ID2", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT2", :useful_2 => "Label2", :user_id => @user.id, :note_type => 0
    Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => @user.id, :note_type => 0  
  end

  after :all do
    Notepad.destroy_all
    @user = User.where(:email => "curator@example.com").first
    @user.destroy
  end

  describe "Add and Delete", :type => :feature do
  
    it "allows individual entry to be deleted", js: true  do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      visit '/notepads'
      #pause
      expect(page).to have_content 'Index: Notepad'
      find(:xpath, "//tr[contains(.,'A1')]/td/a", :text => 'Delete').click
      page.accept_alert
      sleep(1)
      items = Notepad.where(:user_id => @user.id)
      #pause
      #puts items.to_json.to_s
      expect(items.count).to eq(2)
    end

    it "allows all entries to be deleted", js: true  do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      visit '/notepads'
      expect(page).to have_content 'Index: Notepad'
      click_link 'Delete All'
      page.accept_alert
      sleep(1)
      items = Notepad.where(:user_id => @user.id)
      #pause
      #puts items.to_json.to_s
      expect(items.count).to eq(0)
    end

  end

end