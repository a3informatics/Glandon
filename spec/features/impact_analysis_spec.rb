require 'rails_helper'

describe "Impact Analysis", type: :feature  do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include NameValueHelpers
  include D3GraphHelpers
  include DownloadHelpers

  def sub_dir
    return 'features/impact_analysis'
  end 

  after :all do
    Token.destroy_all
    clear_downloads
    ua_destroy
  end

  after :each do
    ua_logoff
  end

  describe "Impact Analysis, Code List, Curator user", type: :feature, js: true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      ua_create
      nv_destroy
      nv_create(parent: '10', child: '999')
      prep_data
    end

    before :each do
      ua_curator_login
    end

    def prep_data 
      @thesaurus = Thesaurus.create({ identifier: 'TEST', label: 'Test Thesaurus' })

      @codelist = Thesaurus::ManagedConcept.find_minimum(Uri.new( uri: 'http://www.cdisc.org/C20587/V1#C20587' ))
      @subset = @codelist.create_subset 
      @extension = @codelist.create_extension
      @subset2 = @thesaurus.add_subset(@extension.id)
    end

    it "allows to show Impact of a Code List, graph view" do
      click_navbar_code_lists
      wait_for_ajax 20 
      
      impact_analysis @codelist.scoped_identifier, '1.0.0', 'CDISC' 
      expect(page).to have_content 'Showing Managed Items impacted by Age Group C20587 v1.0.0.'
      
      check_node_count 4 

      # Node Selection, Node Actions 
      find_node('C20587').click
      check_node 'C20587', :codelist, true
      check_actions [:history]
      check_actions_disabled [:load_impact]

      # Deselect
      find_node('C20587').click 
      check_node 'C20587', :codelist, false

      # Search
      fill_in 'd3-search', with: 'NP'
      ui_press_key :return 

      check_node_count 1, 'g.node.selected.search-match'
      check_node 'NP000010P', :codelist, true

      find('#d3-clear-search').click
      check_node_count 0, 'g.node.search-match'
      find_node('NP000010P').click # Deselect

      # Node Hover 
      sleep 1.5 # Sleep until graph animation finishes
      find_node('C20587E').hover
      expect(page).to have_css('.graph-tooltip', text: "Code List\nAge Group C20587E v0.1.0", visible: true)

      # View History 
      find_node('NP000010P').click
      
      w = window_opened_by { click_action :history }
      within_window w do
        expect(page).to have_content 'Version History of \'NP000010P\''
      end
      w.close

      # Load Impact for Items in Graph  
      click_action :load_impact
      wait_for_ajax 10 
      check_alert 'Item has no Impact'

      find_node('C20587E').click
      click_action :load_impact
      wait_for_ajax 10 

      check_actions_disabled [:load_impact] # Check Load Impact Button disabled after pressed 
      check_node_count 5
      check_node 'NP000011P', :codelist

      find_node('NP000011P').click
      click_action :load_impact
      wait_for_ajax 10 

      check_node_count 6
      check_node 'TEST', :terminology
    end

    it "allows to show and download Impact of a Code List, table view" do
      click_navbar_code_lists
      wait_for_ajax 20 
      impact_analysis @codelist.scoped_identifier, '1.0.0', 'CDISC' 
  
      # Check table data and info
      find('.tab-option', text: 'Table View').click 
      ui_check_table_info('managed-items', 1, 4, 4)
      ui_check_table_cell('managed-items', 1, 2, '1.0.0')
      ui_check_table_cell('managed-items', 1, 3, 'C20587')
      ui_check_table_cell('managed-items', 1, 4, 'Age Group')
      ui_check_table_cell('managed-items', 1, 5, '2007-03-06 Release')

      expect(page).to have_button 'CSV'
      expect(page).to have_button 'Excel'

      # Download CSV  
      click_button "CSV"
      file = download_content 
      expect(file).to eq read_text_file_2(sub_dir, "impact_csv_expected.csv")
    end

  end

  def impact_analysis(identifier, version, owner = "")
    ui_table_search('index', "#{ identifier }" )
    find(:xpath, "//tr[contains(.,'#{ owner.empty? ? identifier : owner }')]/td/a").click
    wait_for_ajax 10
    context_menu_element_v2('history', version, :impact_analysis )
    wait_for_ajax 10 
    expect(page).to have_content('Impact Analysis')
  end 

end
