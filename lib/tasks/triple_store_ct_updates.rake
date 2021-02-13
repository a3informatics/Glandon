# Triple Store CT Updates Rake Task
#
# @author Dave Iberson-Hurst
# @since 3.9.1
namespace :triple_store do

  desc "Triple Store CT Updates"

  @changes = {}
  @to_ttl = []

  # Identify Updates
  def identify_updates
    query_string = %Q{
      SELECT DISTINCT ?s ?l ?v ?i ?sv WHERE 
      {
        ?s rdf:type #{Thesaurus::ManagedConcept.rdf_type.to_ref} .
        ?s isoT:creationDate ?cd .
        FILTER (?cd > "2020-09-26T00:00:00+00:00"^^xsd:dateTime || ?cd = "2016-01-01T00:00:00+00:00"^^xsd:dateTime)
        ?s isoT:hasState ?st .
        ?s isoT:hasIdentifier ?si .
        ?si isoI:hasScope/isoI:shortName "Sanofi" .
        ?s isoC:label ?l .
        ?si isoI:version ?v .
        ?si isoI:identifier ?i .
        ?si isoI:semanticVersion ?sv .
      } ORDER BY ?l ?v
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR])
    items = query_results.by_object_set([:s, :l, :v, :i, :sv])
    display_results("Updates", items, ["Uri", "Label", "Ver", "Identifier", "Semantic Ver"], [0, 75, 0, 0, 0])
    items
  end

  def item_belongs?(uri, predicate)
    query_string = %Q{
      SELECT (count(?e) as ?c) WHERE 
      { 
        ?e th:#{predicate} #{uri.to_ref}
      } GROUP BY ?s 
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    query_results.by_object(:c).first.to_i == 1
  end

  def identify_current_children(uri)
    query_string = %Q{
      SELECT DISTINCT ?s WHERE 
      {
        #{uri.to_ref} th:narrower ?s .
      } ORDER BY ?s
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    query_results.by_object(:s)
  end

  def identify_previous_children(uri)
    query_string = %Q{
      SELECT DISTINCT ?s WHERE 
      {
        #{uri.to_ref} isoT:hasPreviousVersion/th:narrower ?s .
      } ORDER BY ?s
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    query_results.by_object(:s)
  end

  def identify_previous(uri)
    query_string = %Q{
      SELECT DISTINCT ?s WHERE 
      {
        #{uri.to_ref} isoT:hasPreviousVersion ?s .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    return nil if query_results.empty?
    query_results.by_object(:s).first
  end

  def subsets?(uri)
    Sparql::Query.new.query("ASK { #{uri.to_ref} th:subsets ?x }", "", [:th]).ask?
  end

  def subset_master(uri)
    query_string = %Q{
      SELECT DISTINCT ?s WHERE 
      {
        #{uri.to_ref} th:subsets ?s
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    return nil if query_results.empty?
    query_results.by_object(:s).first
  end

  def extends?(uri)
    Sparql::Query.new.query("ASK { #{uri.to_ref} th:extends ?x }", "", [:th]).ask?
  end

  def extension_master(uri)
    query_string = %Q{
      SELECT DISTINCT ?s WHERE 
      {
        #{uri.to_ref} th:extends ?s
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR, :th])
    return nil if query_results.empty?
    query_results.by_object(:s).first
  end

  def identify_summary_changes(items)
    results = []
    items.each do |x| 
      curr_children = identify_current_children(x[:s])
      prev_children = identify_previous_children(x[:s])
      created = curr_children.map{|x| x.to_s} - prev_children.map{|x| x.to_s}
      deleted = prev_children.map{|x| x.to_s} - curr_children.map{|x| x.to_s}
      results << {
        uri: x[:s], 
        current_count: curr_children.count, 
        previous_count: prev_children.count, 
        created_count: created.count, 
        deleted_count: deleted.count, 
        subsets: subsets?(x[:s]) ? "Sub" : "",
        extends: extends?(x[:s]) ? "Ext" : "",
        difference: curr_children.count != curr_children.count || created.any? || deleted.any? ? "Y" : ""
      }
    end
    display_results("Changes - Summary", results, ["Uri", "Current", "Previous", "Created", "Deleted", "Subsets", "Extends", "Difference"])
    results
  end

  def custom_properties_remove_duplicates!(pairs)
    results = pairs.uniq do |x|
      [x[:name], x[:value]]
    end
    results
  end

  def custom_properties_resolve!(pairs)
    results = []
    names = pairs.map{|x| x[:name]}.uniq
    names.each do |name|
      values = pairs.select { |x| x[:name] == name }
      if values.length == 1
        results << values.first 
      else
        set = false
        values.each do |y|
          break if set
          use = (y[:value].is_a?(String) && y[:value].length > 0) || ([true, false].include? y[:value] && y[:value])
          results << y if use
          set = use
        end
        results << values.first unless set        
      end
    end
    results 
  end

  def custom_properties_difference(current, curr_child, prev_child, curr_child_cp, prev_child_cp)
    @changes[current.identifier][:items][curr_child.identifier] = { action: :update, uri: prev_child.uri.to_s, custom_properties: {} } unless @changes[current.identifier][:items].key?(curr_child.identifier)
    names = curr_child_cp.map{|x| x[:name]}.uniq
    names.each do |name|
      curr = curr_child_cp.find { |x| x[:name] == name }
      prev = prev_child_cp.find { |x| x[:name] == name }
      next if curr == prev
      @changes[current.identifier][:items][curr_child.identifier][:custom_properties][name] = curr[:value]
    end
  end

  def custom_properties_build_new(current, curr_child, curr_child_cp)
    @changes[current.identifier][:items][curr_child.identifier] = { action: :action, uri: curr_child.uri.to_s, custom_properties: {} } unless @changes[current.identifier][:items].key?(curr_child.identifier)
    names = curr_child_cp.map{|x| x[:name]}.uniq
    names.each do |name|
      curr = curr_child_cp.find { |x| x[:name] == name }
      @changes[current.identifier][:items][curr_child.identifier][:custom_properties][name] = curr[:value]
    end

    # definitions = curr_child.class.find_custom_property_definitions
    # curr_child.custom_properties.clear
    # definitions.each do |definition|
    #   entry = curr_child_cp.find{ |x| x[:name] == definition.label}
    #   value = entry.nil? ? definition.default : entry[:value]
    #   item = CustomPropertyValue.new(value: value, custom_property_defined_by: definition.uri, applies_to: curr_child.uri, context: [current.uri])
    #   item.uri = item.create_uri(CustomPropertyValue.base_uri)
    #   curr_child.custom_properties << item
    # end
  end

  def item_difference(current, curr_child, prev_child)
    @changes[current.identifier][:items][curr_child.identifier] = { action: :update, uri: prev_child.uri.to_s, custom_properties: {} } unless @changes[current.identifier][:items].key?(curr_child.identifier)
    difference = curr_child.difference(prev_child)
    difference.each {|k,v| @changes[current.identifier][:items][curr_child.identifier][k] = v[:current] if !v.is_a?(Array) && v.key?(:status) && v[:status] == :updated }
    pt = difference.dig(:preferred_term, :label)
    @changes[current.identifier][:items][curr_child.identifier][:preferred_term] = pt[:current] if !pt.nil? && pt[:status] == :updated
    @changes[current.identifier][:items][curr_child.identifier][:synonym] = curr_child.synonyms_to_a if curr_child.synonyms_to_a != prev_child.synonyms_to_a
  end

  def item_build_new(current, curr_child)
    action = curr_child.uri.to_s.start_with?("http://www.cdisc.org/") ? :refer : :create
    @changes[current.identifier][:items][curr_child.identifier] = { action: action, uri: curr_child.uri.to_s, custom_properties: {} } unless @changes[current.identifier][:items].key?(curr_child.identifier)
    properties = curr_child.to_h.slice(:identifier, :notation, :definition, :label, :extensible)
    properties.each {|k,v| @changes[current.identifier][:items][curr_child.identifier][k] = v }
    pt = curr_child.to_h.dig(:preferred_term, :label)
    @changes[current.identifier][:items][curr_child.identifier][:preferred_term] = pt unless pt.nil?
    @changes[current.identifier][:items][curr_child.identifier][:preferred_term] = curr_child.label if pt.nil?
    @changes[current.identifier][:items][curr_child.identifier][:synonym] = curr_child.synonyms_to_a unless curr_child.synonyms_to_a.empty?
  end

  def item_remove(current, curr_child)
    @changes[current.identifier][:items][curr_child.identifier] = { action: :remove, uri: curr_child.uri.to_s, custom_properties: {} } unless @changes[current.identifier][:items].key?(curr_child.identifier)
  end

  def code_list_build_new(current)
    properties = current.to_h.slice(:identifier, :notation, :definition, :label, :extensible)
    properties.each {|k,v| @changes[current.identifier][k] = v} 
    pt = current.to_h.dig(:preferred_term, :label)
    @changes[current.identifier][:preferred_term] = pt unless pt.nil?
    @changes[current.identifier][:items][curr_child.identifier][:preferred_term] = current.label if pt.nil?
    @changes[current.identifier][:synonyms] = current.synonyms_to_a unless current.synonyms_to_a.empty?
  end

  def item_different?(current, previous, curr_child, prev_child)
    curr_child_cp = custom_properties_resolve!(custom_properties_remove_duplicates!(curr_child.custom_properties.name_value_pairs))
    prev_child_cp = prev_child.custom_properties.name_value_pairs
    cp_diff = curr_child_cp != prev_child_cp
    return false unless curr_child.diff?(prev_child) || cp_diff
    item_difference(current, curr_child, prev_child)
    custom_properties_difference(current, curr_child, prev_child, curr_child_cp, prev_child_cp)
    true
  end

  def item_new?(current, curr_child)
    curr_child_cp = custom_properties_resolve!(custom_properties_remove_duplicates!(curr_child.custom_properties.name_value_pairs))
    item_build_new(current, curr_child)
    custom_properties_build_new(current, curr_child, curr_child_cp)
    true
  end

  def code_list_exists?(current, previous)
    @changes[current.identifier] = {action: :new_version, uri: previous.uri.to_s, identifier: previous.identifier, subsets: subsets?(current.uri), extends: extends?(current.uri), items: {}} unless @changes.key?(current.identifier)
    @changes[current.identifier][:subset_of] = subset_master(current.uri).to_s if @changes[current.identifier][:subsets]
    @changes[current.identifier][:extension_of] = extension_master(current.uri).to_s if @changes[current.identifier][:extends]
    true
  end

  def code_list_new?(current)
    @changes[current.identifier] = {action: :create, uri: current.uri.to_s, identifier: current.identifier, subsets: subsets?(current.uri), extends: extends?(current.uri), items: {}} unless @changes.key?(current.identifier)
    @changes[current.identifier][:subset_of] = subset_master(current.uri).to_s if @changes[current.identifier][:subsets]
    @changes[current.identifier][:extension_of] = extension_master(current.uri).to_s if @changes[current.identifier][:extends]
    code_list_build_new(current)
    true
  end

  def identify_detailed_changes(items)
    items.each do |x|
      warning_count = 0
      results = []
      curr_children = identify_current_children(x[:s])
      prev_children = identify_previous_children(x[:s])
      created = curr_children.map{|x| x.to_s} - prev_children.map{|x| x.to_s}
      deleted = prev_children.map{|x| x.to_s} - curr_children.map{|x| x.to_s}
      matched = prev_children.map{|x| x.to_s} & curr_children.map{|x| x.to_s}
      current = Thesaurus::ManagedConcept.find_full(x[:s])
      previous_uri = identify_previous(x[:s])
      previous = previous_uri.nil? ? nil : Thesaurus::ManagedConcept.find_full(previous_uri)

      if previous.nil?
        code_list_new?(current)
        #@to_ttl << {type: :code_list, item: current}
      else
        code_list_exists?(current, previous)
      end

      created.each do |curr_uri_s|
        curr_child = find_child(curr_uri_s)
        curr_child.load_custom_properties(current) unless curr_child.nil?
        prev_child = child_by_identifier(curr_child, previous) unless curr_child.nil?
        prev_child.load_custom_properties(previous) unless prev_child.nil?
        if curr_child.nil?
          results << {
            uri: curr_uri_s, 
            different: true,
            checked: "N",
            type: "Created",
            notes: "Find failed",
            warning: "***"
          }
          warning_count += 1
        elsif prev_child.nil?
          #diff = previous.nil? ? true : item_new?(current, curr_child)
          diff = item_new?(current, curr_child)
          notes = previous.nil? ? "1st version of CL" : "No previous child"
          results << {
            uri: curr_uri_s, 
            different: diff,
            checked: "",
            type: "Created",
            notes: notes,
            warning: ""
          }
          #@to_ttl << {type: :code_list_item, item: curr_child} if !previous.nil? && item_belongs?(curr_child.uri, "narrower")
        else
          diff = item_different?(current, previous, curr_child, prev_child)
          results << {
            uri: curr_uri_s, 
            different: diff,
            checked: "",
            type: "Updated",
            notes: "",
            warning: diff ? "" : ""
          }
        end
      end
      matched.each do |match_uri_s|
        curr_child = find_child(match_uri_s)
        prev_child = child_by_identifier(curr_child, previous) unless curr_child.nil?
        diff = item_different?(current, previous, curr_child, prev_child)
        results << {
          uri: match_uri_s, 
          different: diff,
          checked: "",
          type: "Matched",
          notes: "",
          warning: diff ? "***" : ""
        }
      end
      deleted.each do |match_uri_s|
        curr_child = find_child(match_uri_s)
        item_remove(current, curr_child)
        results << {
          uri: match_uri_s, 
          different: false,
          checked: "",
          type: "Remove",
          notes: "",
          warning: ""
        }
      end
      display_results("Detail: #{x[:i]}, Warning Count: #{warning_count}", results, ["Uri", "Different", "Checked", "Type", "Notes", "Warning"])
    end
  end

  def child_by_identifier(match_this, collection)
    return nil if collection.nil?
    collection.narrower.find{|x| x.identifier == match_this.identifier}
  end

  def find_child(uri_s)
    Thesaurus::UnmanagedConcept.find_full(Uri.new(uri: uri_s))
  rescue => e
    nil
  end
        
  def write_results
    time_now = Time.now.strftime("%FT%H-%M-%S")
    full_path = Rails.root.join "public/test/triple_store_migration_#{time_now}.yaml"
    File.open(full_path, "w+") do |f|
      f.write(@changes.to_yaml)
    end
  end

  def final_summary
    @changes.each do |cl, cl_entry|
      results = []
      cl_entry[:items].each do |cli, cli_entry|
        record = {cli: cli, cli_action: cli_entry[:action]}
        details = cli_entry.dup
        text = []
        details.except(:action, :uri).each { |k,v| text << "#{k}: #{v}" unless v.blank? }
        record[:details] = text.any? ? text.first : ""
        results << record
        if text.length > 1
          (1..text.length).each do |x|
            results << {cli: "", cli_action: "", details: text[x]} unless text[x].nil?
          end
        end
      end
      display_results("#{cl} Changes. Action: #{cl_entry[:action]}, Subsets: #{cl_entry[:subsets]}, Extends: #{cl_entry[:extends]}", results, ["Item", "Item Action", "Notes"], [0, 0, 150])
    end
  end

  # Actual rake task
  task :ct_updates => :environment do

    include RakeDisplay

    items = identify_updates
    identify_summary_changes(items)
    identify_detailed_changes(items)
    final_summary
    write_results
  end

end