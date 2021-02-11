namespace :triple_store do

  desc "Triple Store CT Engine"

  def latest_version(identifier)
    query_string = %{
      SELECT DISTINCT ?s ?v WHERE         
      {             
        ?s rdf:type th:ManagedConcept .
        ?s th:identifier "#{identifier}" .
        ?s isoT:hasIdentifier ?si .
        ?si isoI:hasScope/isoI:shortName "Sanofi" .
        ?si isoI:version ?v .
       } ORDER BY DESC(?v)
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    items = query_results.by_object_set([:s, :v])
    items.first[:s]
  end

  def new_version(item)
    new_item = item.create_next_version
    #abort("Errors: new_version, #{new_item.errors.full_messages.to_sentence}") if new_item.errors.any?
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
    if action_hash.key?(:synonym)
      action_hash[:synonym].each do |s|
        synonym = Thesaurus::Synonym.where_only_or_create(s)
        params[:synonym] << synonym.uri
      end
    end
    new_child = Thesaurus::ManagedConcept.new(params)
    new_child.set_initial(params[:identifier])
    new_child.creation_date = new_child.last_change_date 
    new_child.create_or_update(:create, true) if new_child.valid?(:create) && new_child.create_permitted?
    abort("Errors: create_version, #{new_child.errors.full_messages.to_sentence}") if new_child.errors.any?
    new_child
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
    parent.add_referenced_children([{id: uri.to_id, context_id: parent.id}])
    Thesaurus::UnmanagedConcept.find_full(uri)
  end

  def process_updates(parent, child, action_hash)
    [:definition, :notation, :label, :preferred_term, :synonym].each do |x|
      next if action_hash.dig(x).nil?
      child = Thesaurus::UnmanagedConcept.find_full(child.uri)
      params = {}
      params[x] = action_hash.dig(x)
      params[x] = params[x].join(";") if x == :synonym 
      child = child.update_with_clone(params, parent) 
    end
    child
  end

  def process_custom_properties(parent, child, action_hash)
    return if action_hash.dig(:custom_properties).nil?        
    child.load_custom_properties(parent)
    action_hash.dig(:custom_properties).each do |name, value|
      cp = child.custom_properties.property(name)
      params = {}
      params[name] = value
      cp.update_and_clone(params, parent)
    end
  end

  def process_cli_action(parent, identifier, action_hash, parent_hash)
    action = action_hash.dig(:action)
    if action == :update
      child = Thesaurus::UnmanagedConcept.find_full(Uri.new(uri: action_hash.dig(:uri)))
      new_child = process_updates(parent, child, action_hash)
      process_custom_properties(parent, new_child, action_hash)
    elsif action == :create
      new_child = add_child(parent, action_hash)
      process_custom_properties(parent, new_child, action_hash)
    elsif action == :refer
      if parent_hash.dig(:subsets)
        source = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: parent_hash.dig(:subset_of)))
        subset = parent.is_ordered_objects
        subset.add([Uri.new(uri: action_hash[:uri]).to_id], source)
        new_child = Thesaurus::UnmanagedConcept.find_full(Uri.new(uri: action_hash[:uri]))
        process_custom_properties(parent, new_child, action_hash)
      else
        new_child = add_referenced_child(parent, action_hash)
        process_custom_properties(parent, new_child, action_hash)
      end
    elsif action == :remove
      if parent_hash.dig(:subsets)
        subset = parent.is_ordered_objects
        items = subset.ordered_list
byebug
        item = items.find{ |x| x.item == Uri.new(uri: action_hash[:uri])}
        subset.remove([item.id])
      else
        puts "Error: CLI remove action. Extends: #{parent_hash.dig(:extends)}. Uri: #{action_hash[:uri]}"
      end  
    else
      puts "Error: CLI action"
    end
  end

  def process_cl_action(identifier, action_hash)
    item = nil
    return if action_hash.dig(:items).empty?
    puts "Action: #{identifier}"
    action = action_hash.dig(:action)
    if action == :new_version
      uri = latest_version(identifier)
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
      process_cli_action(item, cli, cli_action_hash, action_hash)
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