require 'rails_helper'

describe "the login process", :type => :feature do
  
  before :each do
    user = FactoryGirl.create(:user)
  end

  it "allows valid credentials" do
    visit '/users/sign_in'
    fill_in 'Email', with: 'user@example.com'
    fill_in 'Password', with: 'example1234'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'
  end

  it "rejects invalid credentials" do
    visit '/users/sign_in'
    fill_in 'Email', with: 'user@example.com'
    fill_in 'Password', with: 'example1234x'
    click_button 'Log in'
    expect(page).to have_content 'Log in'
  end

end