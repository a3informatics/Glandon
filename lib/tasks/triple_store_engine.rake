namespace :triple_store do

  desc "Draft Updates"

  def new_version(uri)
    item = Thesaurus::ManagedConcept.find_minimum(uri)
    item.create_next_version
  end

  def update_code_list_item(entry)
  end

  def process
    actions.each do |k, v|
      action = v.dig(:cl_action)
      uri = Uri.new(uri: v.dig(:cl_uri))
      if action == :new_version
        item = new_version(uri)
      else
        item = Thesaurus::ManagedConcept.find_minimum(uri)
      end
      items = v.dig(:items)
      items.each do |cli, cli_details|
        tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: cli_details.dig(:cli_uri)))
        tc.update_with_clone({definition: cli_details.dig(:definition, :current)}, item) unless cli_details.dig(:definition, :current).nil?
        unless cli_details.dig(:custom_properties).nil?        
          tc.load_custom_properties
          cli_details.dig(:custom_properties).each do |name, value|
            cp = tc.custom_properties.property(name)
            params = {}
            params[name] = value
            cp.update_and_clone(params, item)
          end
        end
        #unless params.key?(:custom_property)
        #params = params[:custom_property]
        #cp = CustomPropertyValue.find_children(protect_from_bad_id(params))
        #cp.update_and_clone(params, parent)
      end
    end
  end

  # Actual rake task
  task :engine => :environment do
  end

end