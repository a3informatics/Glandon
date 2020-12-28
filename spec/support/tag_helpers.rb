# Requires D3GraphHelpers, UiHelpers and WaitForAjaxHelper to be included
module TagHelpers

  # Data
  def load_test_tags
    load_test_file_into_triple_store("tag_test_data.ttl")
  end

  def make_tagged_item_data(tag_items = true)
    root = IsoConceptSystem.root
    tag1 = root.add( label: "Tag1", description: "Tag1" )
    tag2 = root.add( label: "Tag2", description: "Tag2" )
    tag1_1 = tag1.add( label: "Tag1_1", description: "Tag1_1" )

    ct = Thesaurus.create( { identifier: "TEST", label: "Test Thesaurus"} )
    tc = Thesaurus::ManagedConcept.create
    tc2 = Thesaurus::ManagedConcept.create
    uc = tc.add_child( { identifier: 'SRVR' } )
    bc = BiomedicalConceptInstance.create ( { identifier: 'TESTBC', label: "Test BC" } )
    form = Form.create( { identifier: 'TESTF', label: "Test Form" } )

    if tag_items == true
      ct.add_tag(tag1_1.id)
      ct.add_tag(tag2.id)
      tc.add_tag(tag2.id)
      tc2.add_tag(tag2.id)
    end
  end

  # Edit Tags in the system

  def go_to_tags
    click_navbar_tags
    expect(page).to have_content 'Tags Editor'
    wait_for_ajax 10
    find('#main_area').scroll_to :bottom
  end

  def create_tag(parent, label, description, success = true, error_msg = '')
    tag_count = node_count

    find_node(parent).click if !find_node(parent)[:class].include? 'selected'
    click_action :add_child

    ui_in_modal do
      within( find('#generic-editor') ) do
        fill_in 'label', with: label
        fill_in 'description', with: description

        click_on 'Submit'
      end
    end
    wait_for_ajax 10

    if success == true
      check_alert 'Tag created successfully'
      expect( node_count ).to eq( tag_count + 1 )
    else
      expect(page).to have_content error_msg
      click_on 'Close'
    end
  end

  def delete_tag(tag, success = true, error_msg = '')
    tag_count = node_count

    find_node(tag).click if !find_node(tag)[:class].include? 'selected'
    click_action :remove
    ui_confirmation_dialog true
    wait_for_ajax 20

    if success == true
      check_alert 'Tag deleted successfully'
      expect( node_count ).to eq( tag_count - 1 )
    else
      expect(page).to have_content error_msg
    end
  end

  # Edit Tags of an Item

  def edit_tags(identifier)
    context_menu_element_header(:edit_tags)
    wait_for_ajax 20

    expect(page).to have_content identifier if !identifier.empty?
    expect(page).to have_content 'Edit Item Tags'
    find('#main_area').scroll_to :bottom
  end

  def check_tags(tags)
    page.all('#tags .tag').each { |tag| expect(tags.include? tag) }
    expect(count_tags).to eq tags.count
  end

  def count_tags
    page.all('#tags .tag').count
  end

  def attach_tag(tag)
    tag_count = count_tags

    fill_in 'd3-search', with: tag
    ui_press_key :enter
    find('#d3-clear-search').click

    click_on '+ Attach Tag'
    wait_for_ajax 10
    expect( count_tags ).to eq tag_count + 1
  end

  def detach_tag(tag)
    tag_count = count_tags

    find('#tags .tag', text: tag).click
    wait_for_ajax 10

    expect( count_tags ).to eq tag_count - 1
  end

end
