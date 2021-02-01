module IsoManagedHelpers

  def check_dates(item, sub_dir, filename, *args)
    expected = read_yaml_file(sub_dir, filename)
    args.each do |a|
      expect(item.send(a)).to be_within(5.seconds).of Time.now
      method = "#{a}=".to_sym
      item.send(method, expected[a].to_time_with_default)
    end
  end

  def fix_dates(item, sub_dir, filename, *args)
    expected = read_yaml_file(sub_dir, filename)
    args.each do |a|
      method = "#{a}=".to_sym
      item.send(method, expected[a].to_time_with_default)
    end
  end

  def fix_dates_hash(actual_hash, sub_dir, filename, *args)
    expected = read_yaml_file(sub_dir, filename)
    args.each do |a|
      actual_hash[a] = expected[a]
    end
  end

  def change_ownership(item, new_ra)
    item.has_identifier.replace_link(:has_scope, item.has_identifier.has_scope.uri, new_ra.ra_namespace.uri)
    item.has_state.replace_link(:by_authority, item.has_state.by_authority.uri, new_ra.uri)
    IsoManagedV2.find_minimum(item.uri)
  end

  def self.make_item_draft(item)
    item.has_state.update(registration_status: "Incomplete", previous_state: "Incomplete")
    IsoManagedV2.find_minimum(item.uri)
  end

  def self.make_item_candidate(item)
    item.has_state.update(registration_status: "Candidate", previous_state: "Incomplete")
    IsoManagedV2.find_minimum(item.uri)
  end

  def self.make_item_recorded(item)
    item.has_state.update(registration_status: "Recorded", previous_state: "Candidate")
    IsoManagedV2.find_minimum(item.uri)
  end

  def self.make_item_qualified(item)
    item.has_state.update(registration_status: "Qualified", previous_state: "Recorded")
    IsoManagedV2.find_minimum(item.uri)
  end

  def self.make_item_standard(item)
    item.has_state.update(registration_status: "Standard", previous_state: "Qualified")
    IsoManagedV2.find_minimum(item.uri)
  end

  def self.make_item_superseded(item)
    item.has_state.update(registration_status: "Superseded", previous_state: "Standard")
    IsoManagedV2.find_minimum(item.uri)
  end

  def self.next_version(item)
    new_item = item.create_next_version
    puts colourize("Error creating next version. Errors: #{new_item.errors.full_messages.to_sentence}", "red") if new_item.errors.any?
    new_item 
  end

  # Document Control UI Helpers

  def dc_check_version(version)
    expect( find('#version') ).to have_content(version)
    expect( find('.semantic-version') ).to have_content(version) 
  end

  def dc_check_version_label(version_label)
    expect( find('#version-label') ).to have_content(version_label) 
    expect( find('#imh_header .version-label') ).to have_content(version_label) unless version_label.eql?('None')
  end

  def dc_check_status(current_status, next_status = nil)
    expect( find('#status .status') ).to have_content(current_status) 
    expect( find('#imh_header .state') ).to have_content(current_status)
    expect( find('#status-next .status') ).to have_content(next_status) unless next_status.nil? 
  end

  def dc_check_current(type)
    current = find('#current')

    case type 
    when :is_current 
      expect( current ).to have_selector('.icon-sel-filled')
    when :not_standard
      expect( current ).to have_content('Item status is not Standard')
    when :can_be_current  
      expect( current ).to have_button('Make Current')
    end 
  end

  def dc_get_current_state
    find('#status .status').text
  end 

  def dc_forward_to(state)
    while not dc_get_current_state.eql?(state) do 
      click_on 'Forward to Next'
      wait_for_ajax 10 
      expect(page).to have_content('Changed Status to')
    end
  end 

  def dc_click_with_dependencies
    find_field( 'with-dependencies' ).find(:xpath, '..').click
  end 


end