namespace :triple_store do

  desc "Draft Updates"

  def new_version(item)
    item.create_next_version
  end

  def create_version(action_hash)
    child = Thesaurus::ManagedConcept.empty_concept
    child[:identifier] = action_hash[:identifier]
    child[:definition] = action_hash[:definition]
    child[:label] = action_hash[:label]
    child[:extensible] = action_hash[:extensible]
    #:preferred_term: Vaccines Severity Response
    #:synonyms: []
    IsoManagedV2.create(child)
  end

  def add_child(parent, action_hash)
    child = Thesaurus::UnmanagedConcept.empty_concept
    child.merge!(params)
    child[:identifier] = Thesaurus::UnmanagedConcept.generated_identifier? ? Thesaurus::UnmanagedConcept.new_identifier : params[:identifier]
    child = Thesaurus::UnmanagedConcept.create(child, parent)
    parent.add_link(:narrower, child.uri)
    child
  end

  def add_referenced_child(parent, action_hash)
    uri = Uri.new(uri: action_hash[:uri])
    parent.add_referenced_child([{id: uri.to_id, context_id: parent.id}])
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
    if action == :update
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: action_hash.dig(:cli_uri)))
      tc.update_with_clone({definition: action_hash.dig(:definition, :current)}, item) unless action_hash.dig(:definition, :current).nil?
      process_custom_properties(parent, tc, action_hash)
    elsif action == :create
      new_tc = add_child(parent, action_hash)
    elsif action == :refer
      new_tc = add_referenced_child(parent, action_hash)
    else
      puts "Errror CLI action"
    end
  end

  def process_cl_action(identifier, action_hash)
    uri = Uri.new(uri: action_hash.dig(:cl_uri))
    item = Thesaurus::ManagedConcept.find_minimum(uri)
    action = action_hash.dig(:action)
    if action == :new_version
      item = new_version(item)
    elsif action == :create
      item = create_version(action_hash)
    else
      puts "Error CL action"
    end
    action_hash.dig(:items).each do |cli, cli_action_hash|
      process_cli_action(item, cli, cli_action_hash)
    end
  end

  def process
    actions.each do |cl, cl_action_hash|
      process_cl_action(cl, cl_action_hash)
    end
  end

  # Actual rake task
  task :engine => :environment do
    process
  end

end