namespace :triple_store do

  desc "Draft Updates"

  @changes = {}
  @to_ttl = []

  # Format results as a simple table
  def display_results(items, labels, widths=[])
    results = [labels]
    results += items.map { |x| x.values }
    max_lengths = results[0].map { |x| x.length }
    unless widths.empty?
      results.each_with_index do |x, j|
        x.each_with_index do |e, i|
          next if widths[i] == 0 
          results[j][i]= "#{e.to_s[0..widths[i]-1]}[...]" if e.to_s.length > widths[i]
        end
      end
    end
    results.each do |x|
      x.each_with_index do |e, i|
        s = e.to_s.length
        max_lengths[i] = s if s > max_lengths[i]
      end
    end
    format = max_lengths.map {|y| "%#{y}s"}.join(" " * 3)
    puts format % results[0]
    puts format % max_lengths.map { |x| "-" * x }
    results[1..-1].each do |x| 
      puts format % x 
    end
    puts "\n\n"
  end

  # Identify Updates
  def identify_updates
    # After the filter line, only use if dont want completely new items
    # FILTER (EXISTS { ?s isoT:hasPreviousVersion ?y } )
    query_string = %Q{
      SELECT DISTINCT ?s ?l ?v ?i ?sv WHERE 
      {
        ?s rdf:type #{Thesaurus::ManagedConcept.rdf_type.to_ref} .
        ?s isoT:hasState ?st .
        ?st isoR:registrationStatus "Incomplete" .
        FILTER (NOT EXISTS { ?s ^isoT:hasPreviousVersion ?x } )
        ?s isoT:hasIdentifier ?si .
        ?si isoI:hasScope/isoI:shortName "Sanofi" .
        ?s isoC:label ?l .
        ?si isoI:version ?v .
        ?si isoI:identifier ?i .
        ?si isoI:semanticVersion ?sv .
      } ORDER BY ?l
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT, :isoR])
    items = query_results.by_object_set([:s, :l, :v, :i, :sv])
    display_results(items, ["Uri", "Label", "Ver", "Identifier", "Semantic Ver"])
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

  def extends?(uri)
    Sparql::Query.new.query("ASK { #{uri.to_ref} th:extends ?x }", "", [:th]).ask?
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
    display_results(results, ["Uri", "Current", "Previous", "Created", "Deleted", "Subsets", "Extends", "Difference"])
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
    @changes[current.identifier][:items][curr_child.identifier] = { action: :create, uri: prev_child.uri.to_s, custom_properties: {} } unless @changes[current.identifier][:items].key?(curr_child.identifier)
    difference = curr_child.difference(prev_child)
    difference.each {|k,v| @changes[current.identifier][:items][curr_child.identifier][k] = v[:current] if !v.is_a?(Array) && v.key?(:status) && v[:status] == :updated }
    pt = difference.dig(:preferred_term, :label)
    @changes[current.identifier][:items][curr_child.identifier][:preferred_term] = pt[:current] if !pt.nil? && pt[:status] == :updated
    @changes[current.identifier][:items][curr_child.identifier][:synonym] = curr_child.synonyms_to_a if curr_child.synonyms_to_a != prev_child.synonyms_to_a
  end

  def item_build_new(current, curr_child)
    action = curr_child.uri.to_s.start_with?("http://www.cdisc.org/") ? :refer : :create
    @changes[current.identifier][:items][curr_child.identifier] = { action: action, cli_uri: curr_child.uri.to_s, custom_properties: {} } unless @changes[current.identifier][:items].key?(curr_child.identifier)
    properties = curr_child.to_h.slice(:identifier, :notation, :definition, :label, :extensible)
    properties.each {|k,v| @changes[current.identifier][:items][curr_child.identifier][k] = v }
    pt = curr_child.to_h.dig(:preferred_term, :label)
    @changes[current.identifier][:items][curr_child.identifier][:preferred_term] = pt unless pt.nil?
    @changes[current.identifier][:items][curr_child.identifier][:preferred_term] = curr_child.label if pt.nil?
    @changes[current.identifier][:items][curr_child.identifier][:synonym] = curr_child.synonyms_to_a unless curr_child.synonyms_to_a.empty?
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
    @changes[current.identifier] = {action: :new_version, cl_uri: previous.uri.to_s, subsets: subsets?(current.uri), extends: extends?(current.uri), items: {}} unless @changes.key?(current.identifier)
    item_difference(current, curr_child, prev_child)
    custom_properties_difference(current, curr_child, prev_child, curr_child_cp, prev_child_cp)
    true
  end

  def item_new?(current, curr_child)
    curr_child_cp = custom_properties_resolve!(custom_properties_remove_duplicates!(curr_child.custom_properties.name_value_pairs))
    @changes[current.identifier] = {action: :new_version, cl_uri: current.uri.to_s, subsets: subsets?(current.uri), extends: extends?(current.uri), items: {}} unless @changes.key?(current.identifier)
    item_build_new(current, curr_child)
    custom_properties_build_new(current, curr_child, curr_child_cp)
    true
  end

  def code_list_new?(current)
    @changes[current.identifier] = {action: :create, cl_uri: current.uri.to_s, subsets: subsets?(current.uri), extends: extends?(current.uri), items: {}} unless @changes.key?(current.identifier)
    code_list_build_new(current)
    true
  end

  def identify_detailed_changes(items)
    items.each do |x| 
      puts "\n"
      puts "#{x[:i]}"
      puts "=" * x[:i].length
      puts ""
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
        results << {
          uri: match_uri_s, 
          different: false,
          checked: "N",
          type: "Deleted",
          notes: "",
          warning: ""
        }
      end
      display_results(results, ["Uri", "Different", "Checked", "Type", "Notes", "Warning"])
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
    time_now = Time.now.strftime("%FT%T")
    full_path = Rails.root.join "public/test/triple_store_migration_#{time_now}.yaml"
    File.open(full_path, "w+") do |f|
      f.write(@changes.to_yaml)
    end
  end

  def flatten_changes
    results = []
    @changes.each do |cl, cl_entry|
      cl_entry[:items].each do |cli, cli_entry|
        cli_entry.each do |entry|
          record = {cl: cl, action: cl_entry[:cl_action], subsets: cl_entry[:subsets], extends: cl_entry[:extends], cli: cli }
          entry.each { |k,v| record[k] = v }
          results << record
        end
      end
    end
    results
  end

  # def items_to_ttl
  #   @to_ttl.each do |x|
  #     item = x[:item]
  #     sparql = Sparql::Update.new
  #     sparql.default_namespace(item.uri.namespace)
  #     if x[:type] == :code_list 
  #       item = adjust_cl(item)
  #       item.serialize(sparql, true, true)
  #     else
  #       item = adjust_cli(item)
  #       item.serialize(sparql)
  #     end
  #     sparql.to_file
  #   end
  # end
  
  # def adjust_cl(item)
  #   uri = item.has_identifier.has_scope.uri
  #   item.has_identifier.has_scope = uri
  #   uri = item.has_state.by_authority.uri
  #   item.has_state.by_authority = uri
  #   item.refers_to = []
  #   item.narrower.each_with_index do |child, index|
  #     item.narrower[index] = adjust_cli(child)
  #     item.narrower[index] = child.uri unless item_belongs?(child.uri, "narrower")
  #     item.refers_to[index] = child.uri unless item.subsets.nil?
  #     item.refers_to[index] = child.uri unless item.extends.nil? && item_belongs?(child.uri, "narrower")
  #   end
  #   item
  # end

  # def adjust_cli(item)
  #   item = item.class.find_full(item.uri)
  #   item.synonym.each_with_index do |syn, index|
  #     next if item_belongs?(syn.uri, "synonym")
  #     item.synonym[index] = syn.uri
  #   end
  #   item.preferred_term = item.preferred_term.uri unless item_belongs?(item.preferred_term.uri, "preferredTerm")
  #   item
  # end

  # Actual rake task
  task :ct_updates => :environment do
    items = identify_updates
    identify_summary_changes(items)
    identify_detailed_changes(items)
    #items_to_ttl
    write_results
  end

end