namespace :triple_store do

  desc "Draft Updates"

  def new_version(item)
    new_item = item.create_next_version
    abort("Errors: new_version, #{new_item.errors.full_messages.to_sentence}") if new_item.errors.any?
  end

  def create_version(action_hash)
    params = Thesaurus::ManagedConcept.empty_concept
    params[:identifier] = action_hash[:identifier]
    params[:notation] = action_hash[:notation]
    params[:definition] = action_hash[:definition]
    params[:label] = action_hash[:label]
    params[:extensible] = action_hash[:extensible]
    pt = Thesaurus::PreferredTerm.where_only_or_create(action_hash[:preferred_term])
    params[:preferred_term] = pt.uri 
    params[:synonym] = []
    action_hash[:synonym].each do |s|
      synonym = Thesaurus::Synonym.where_only_or_create(s)
      params[:synonym] << synonym.uri
    end
    new_child = IsoManagedV2.create(params)
    abort("Errors: create_version, #{new_child.errors.full_messages.to_sentence}") if new_child.errors.any?
  end

  def create_subset(master, action_hash)
    new_mc = create_version(action_hash)
    abort("Errors: create_subset, #{new_mc.errors.full_messages.to_sentence}") if new_mc.errors.any?
    subset = Thesaurus::Subset.create(parent_uri: new_mc.uri)
    abort("Errors: create_subset, #{subset.errors.full_messages.to_sentence}") if subset.errors.any?
    new_mc.add_link(:is_ordered, subset.uri)
    new_mc.add_link(:subsets, master.uri)
    new_mc
  end

  def add_child(parent, action_hash)
    params = Thesaurus::UnmanagedConcept.empty_concept
    params[:identifier] = action_hash[:identifier]
    params[:notation] = action_hash[:notation]
    params[:definition] = action_hash[:definition]
    params[:label] = action_hash[:label]
    child = Thesaurus::UnmanagedConcept.create(params, parent)
    abort("Errors: add_child, #{child.errors.full_messages.to_sentence}") if child.errors.any?
    parent.add_link(:narrower, child.uri)
    child
  end

  def add_referenced_child(parent, action_hash)
    uri = Uri.new(uri: action_hash[:uri])
    parent.add_referenced_child([{id: uri.to_id, context_id: parent.id}])
  end

  def process_updates(parent, child, action_hash)
    [:definition, :notation, :label, :preferred_term, :synonym].each do |x|
      params = {}
      params[x] = action_hash.dig(x)
      child.update_with_clone(params, item) unless action_hash.dig(x).nil?
    end
  end

  def process_custom_properties(parent, child, action_hash)
    return if action_hash.dig(:custom_properties).nil?        
    child.load_custom_properties
    action_hash.dig(:custom_properties).each do |name, value|
      cp = child.custom_properties.property(name)
      params = {}
      params[name] = value
      cp.update_and_clone(params, parent)
    end
  end

  def process_cli_action(parent, identifier, action_hash)
    action = action_hash.dig(:action)
    child = Thesaurus::UnmanagedConcept.find(Uri.new(uri: action_hash.dig(:cli_uri)))
    if action == :update
      new_child = process_updates(parent, child, action_hash)
      process_custom_properties(parent, new_child, action_hash)
    elsif action == :create
      new_child = add_child(parent, action_hash)
      process_custom_properties(parent, new_child, action_hash)
    elsif action == :refer
      if action_hash.dig(:subsets)
        puts "Error: Subset item, not implemented"
      else
        new_child = add_referenced_child(parent, action_hash)
        process_custom_properties(parent, new_child, action_hash)
      end
    else
      puts "Errror: CLI action"
    end
  end

  def process_cl_action(identifier, action_hash)
    return if action_hash.dig(:items).empty?

    puts "Action: #{identifier}"
    
    uri = Uri.new(uri: action_hash.dig(:cl_uri))
    item = Thesaurus::ManagedConcept.find_minimum(uri)
    action = action_hash.dig(:action)
    if action == :new_version
      item = Thesaurus::ManagedConcept.find_with_properties(uri)
      item = new_version(item)
    elsif action == :create
      if action_hash.dig(:subsets)
        master = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: action_hash.dig(:subset_of)))
        item = create_subset(master, action_hash)
      elsif action_hash.dig(:extends)
        puts "Errror: Trying to extend, not implemented"
      else
        item = create_version(action_hash)
      end
    else
      puts "Error: CL action"
    end
    action_hash.dig(:items).each do |cli, cli_action_hash|
      process_cli_action(item, cli, cli_action_hash)
    end
  end

  def read_actions(filename)
    full_path = Rails.root.join "public/test/#{filename}"
    YAML.load_file(full_path)
  end

  def process
    ARGV.each { |a| task a.to_sym do ; end }
    abort("A filename should be supplied") if ARGV.count == 1
    abort("Only a single parameter (a filename) should be supplied") unless ARGV.count == 2
    actions = read_actions(ARGV[1])
    actions.each do |cl, cl_action_hash|
      process_cl_action(cl, cl_action_hash)
    end
  end

  # Actual rake task
  task :ct_engine => :environment do
    process
  end

end