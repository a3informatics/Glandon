module DomainHelpers

  def clone_domain(prefix)
    visit '/users/sign_in'
    expect(page).to have_content 'Log in'  
    fill_in 'Email', with: 'domain_edit@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'
    visit 'sdtm_ig_domains/IG-CDISC_SDTMIGEG?sdtm_ig_domain[namespace]=http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3'
    click_link 'Clone'
    expect(page).to have_content 'Cloning: Electrocardiogram SDTM IG EG (V0.0.0, 3, Standard)'
    ui_check_input('sdtm_user_domain_prefix', 'EG')
    fill_in 'sdtm_user_domain_prefix', with: "#{prefix}"
    fill_in 'sdtm_user_domain_label', with: "Cloned EG"
    click_button 'Clone'   
    expect(page).to have_content 'SDTM Sponsor Domain was successfully created.'
    expect(page).to have_content "Cloned EG"
    find(:xpath, "//tr[contains(.,'#{prefix} Domain')]/td/a", :text => 'History').click
    expect(page).to have_content 'History:'
    find(:xpath, "//tr[contains(.,'#{prefix} Domain')]/td/a", :text => 'Edit').click
    expect(page).to have_content 'Edit:'  
  end

  def load_domain(identifier)
    visit '/users/sign_in'
    expect(page).to have_content 'Log in'  
    fill_in 'Email', with: 'domain_edit@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'  
    click_link 'Domains'
    expect(page).to have_content 'Index: Domains'
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    expect(page).to have_content 'History:'
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
    expect(page).to have_content 'Edit:'  
  end

  def reload_domain(identifier)
    click_link 'Domains'
    expect(page).to have_content 'Index: Domains'
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'History').click
    expect(page).to have_content 'History:'
    find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a", :text => 'Edit').click
    expect(page).to have_content 'Edit:'  
  end

end