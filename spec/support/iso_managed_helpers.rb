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
    Thesaurus::ManagedConcept.find_minimum(item.uri)
  end

  def self.make_item_standard(item)
    item.update_status({registration_status: "Standard", previous_state: "Incomplete"})
  end

  def self.make_item_draft(item)
    item.update_status({registration_status: "Incomplete", previous_state: "Incomplete"})
  end

end