require 'rails_helper'

describe "Dashboard", :type => :feature do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers

  before :all do
    clear_triple_store
    ua_create
  end

  after :all do
    ua_destroy
  end

  it "displays the menu, sys admin (REQ-MDR-UD-060)" do
    ua_sys_admin_login
  #save_and_open_page
    expect(page).to have_css("#main_nav_d")
	  expect(page).to have_link("main_nav_el")
	  expect(page).to have_link("main_nav_at")
    expect(page).to have_link("main_nav_bj")
	  expect(page).to_not have_link("main_nav_u")
	  expect(page).to_not have_link("main_nav_ahr")
    expect(page).to_not have_link("main_nav_ics")
    expect(page).to_not have_link("main_nav_ma")
    expect(page).to_not have_link("main_nav_te")
    expect(page).to_not have_link("main_nav_ct")
    expect(page).to_not have_link("main_nav_bct")
    expect(page).to_not have_link("main_nav_bc")
    expect(page).to_not have_link("main_nav_f")
    expect(page).to_not have_link("main_nav_sm")
    expect(page).to_not have_link("main_nav_sig")
    expect(page).to_not have_link("main_nav_aig")
    expect(page).to_not have_link("main_nav_sd")
  end

  it "displays the menu, content admin (REQ-MDR-UD-060)" do
    ua_content_admin_login
    expect(page).to have_css("#main_nav_d")
	  expect(page).to have_link("main_nav_u")
	  expect(page).to have_link("main_nav_bj")
	  expect(page).to have_link("main_nav_at")
	  expect(page).to have_link("main_nav_ahr")
    expect(page).to have_link("main_nav_ics")
    expect(page).to have_link("main_nav_ma")
    expect(page).to have_link("main_nav_te")
    expect(page).to have_link("main_nav_ct")
    expect(page).to have_link("main_nav_bct")
    expect(page).to have_link("main_nav_bc")
    expect(page).to have_link("main_nav_f")
    expect(page).to have_link("main_nav_sm")
    expect(page).to have_link("main_nav_sig")
    expect(page).to have_link("main_nav_aig")
    expect(page).to have_link("main_nav_sd")
  end

  it "displays the menu, curator (REQ-MDR-UD-060)" do
    ua_curator_login
    expect(page).to have_css("#main_nav_d")
	  expect(page).to have_link("main_nav_ahr")
	  expect(page).to have_link("main_nav_ics")
    expect(page).to have_link("main_nav_ma")
    expect(page).to have_link("main_nav_te")
    expect(page).to have_link("main_nav_ct")
    expect(page).to have_link("main_nav_bct")
    expect(page).to have_link("main_nav_bc")
    expect(page).to have_link("main_nav_f")
    expect(page).to have_link("main_nav_sm")
    expect(page).to have_link("main_nav_sig")
    expect(page).to have_link("main_nav_aig")
    expect(page).to have_link("main_nav_sd")
	  expect(page).to_not have_link("main_nav_bj")
    expect(page).to_not have_link("main_nav_u")
  end

  it "displays the menu, reader (REQ-MDR-UD-060)" do
    ua_reader_login
    expect(page).to have_css("#main_nav_d")
    expect(page).to have_link("main_nav_ics")
    expect(page).to have_link("main_nav_ma")
    expect(page).to have_link("main_nav_te")
    expect(page).to have_link("main_nav_ct")
    expect(page).to have_link("main_nav_bct")
    expect(page).to have_link("main_nav_bc")
    expect(page).to have_link("main_nav_f")
    expect(page).to have_link("main_nav_sm")
    expect(page).to have_link("main_nav_sig")
    expect(page).to have_link("main_nav_aig")
    expect(page).to have_link("main_nav_sd")
    expect(page).to_not have_link("main_nav_bj")
    expect(page).to_not have_link("main_nav_u")
    expect(page).to_not have_link("main_nav_im")
    expect(page).to_not have_link("main_nav_ahr")
  end

  it "displays the menu, terminology reader (REQ-MDR-UD-060)" do
    ua_term_reader_login
    expect(page).to have_css("#main_nav_d")
    expect(page).to have_link("main_nav_te")
    expect(page).to have_link("main_nav_ct")
    expect(page).to_not have_link("main_nav_ics")
    expect(page).to_not have_link("main_nav_ma")
    expect(page).to_not have_link("main_nav_bj")
    expect(page).to_not have_link("main_nav_u")
    expect(page).to_not have_link("main_nav_im")
    expect(page).to_not have_link("main_nav_ahr")
    expect(page).to_not have_link("main_nav_bct")
    expect(page).to_not have_link("main_nav_bc")
    expect(page).to_not have_link("main_nav_f")
    expect(page).to_not have_link("main_nav_sm")
    expect(page).to_not have_link("main_nav_sig")
    expect(page).to_not have_link("main_nav_aig")
    expect(page).to_not have_link("main_nav_sd")
  end

  it "displays the menu, terminology curator (REQ-MDR-UD-060)" do
    ua_term_curator_login
    expect(page).to have_css("#main_nav_d")
    expect(page).to have_link("main_nav_te")
    expect(page).to have_link("main_nav_ct")
    expect(page).to_not have_link("main_nav_ics")
    expect(page).to_not have_link("main_nav_ma")
    expect(page).to_not have_link("main_nav_bj")
    expect(page).to_not have_link("main_nav_u")
    expect(page).to_not have_link("main_nav_ahr")
    expect(page).to_not have_link("main_nav_bct")
    expect(page).to_not have_link("main_nav_bc")
    expect(page).to_not have_link("main_nav_f")
    expect(page).to_not have_link("main_nav_sm")
    expect(page).to_not have_link("main_nav_sig")
    expect(page).to_not have_link("main_nav_aig")
    expect(page).to_not have_link("main_nav_sd")
  end

end
