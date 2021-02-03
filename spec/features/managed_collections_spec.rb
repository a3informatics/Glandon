require 'rails_helper'

describe "ISO Managed Collections", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include ItemsPickerHelpers
  include TokenHelpers
  include ManagedCollectionFactory
  include BiomedicalConceptInstanceFactory
  include SdtmSponsorDomainFactory 

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  def prep_data
    item_1 = create_managed_collection("MC1", "Item 1")
    item_2 = create_managed_collection("MC2", "Item 2")
    item_1.add_item([
      create_sdtm_sponsor_domain('TSTSD', 'Test 1', 'AA').id, 
      create_biomedical_concept_instance('TSTBC', 'Test2').id
    ])
  end

  describe "Basic Operations, Curator user", :type => :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      prep_data
    end
    
    it "allows access to index page" do
      click_navbar_mcs
      wait_for_ajax 10
      expect(page).to have_content 'Index: Managed Collections'
      find(:xpath, "//th[contains(.,'Identifier')]").click # Order
      ui_check_table_info("index", 1, 2, 2)
      ui_check_table_row("index", 1, ["S-cubed", "MC1", "Item 1"])
      ui_check_table_row("index", 2, ["S-cubed", "MC2", "Item 2"])
    end

    it "allows the history page to be viewed" do
      click_navbar_mcs
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'MC1')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'MC1\''
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 5, "Item 1")
    end

    it "history allows the show page to be viewed" do
      click_navbar_mcs
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'MC1')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'MC1\''
      context_menu_element_v2('history', "MC1", :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: Managed Collection'
      ui_check_table_info("managed-items", 1, 2, 2)
      ui_check_table_row("managed-items", 1, [ "", "S-cubed", "0.1.0", "TSTBC", "Test2"])
    end

  end


  describe "Create, delete actions, Curator user", :type => :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "allows to create a new Managed Collection" do
      click_navbar_mcs
      wait_for_ajax 10

      click_on 'New Managed Collection'
      ui_in_modal do
        fill_in 'identifier', with: 'MC Test'
        fill_in 'label', with: 'Test Label'
        click_on 'Submit'
      end

      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'MC Test\''
    end

    it "create Managed Collection, clear fields, field validation" do
      click_navbar_mcs
      wait_for_ajax 20
      click_on 'New Managed Collection'

      ui_in_modal do
        # Empty fields validation
        fill_in 'identifier', with: 'MC Test'
        click_on 'Submit'

        expect(page).to have_content('Field cannot be empty', count: 1)
        expect(page).to have_selector('.form-group.has-error', count: 1)

        click_on 'Clear fields'

        expect(find_field('identifier').value).to eq('')
        expect(find_field('label').value).to eq('')

        # Special characters validation
        fill_in 'identifier', with: 'MæC Test'
        fill_in 'label', with: 'Test Label 2'

        click_on 'Submit'
        wait_for_ajax 10

        expect(page).to have_content('contains invalid characters', count: 1)

        # Duplicate identifier validation
        fill_in 'identifier', with: 'MC Test'
        fill_in 'label', with: 'Test Label 2'

        click_on 'Submit'
        wait_for_ajax 10

        expect(page).to have_content 'already exists in the database'
        click_on 'Close'
      end
    end

    it "allows to delete a Managed Collection" do
      prep_data
      mc_count = ManagedCollection.all.count

      click_navbar_mcs
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'MC1')]/td/a", :text => 'History').click
      wait_for_ajax 10

      context_menu_element_v2('history', 'Incomplete', :delete)
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_content "No versions found"
      expect( ManagedCollection.all.count ).to eq mc_count-1
    end



  end


end
