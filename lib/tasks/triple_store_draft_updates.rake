namespace :triple_store do

  desc "Draft Updates"

  @changes = {}

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

  def custom_properties_difference(current, curr_child, curr_child_cp, prev_child_cp)
    @changes[current.identifier][:items][curr_child.identifier] = [] unless @changes[current.identifier][:items].key?(curr_child.identifier)
    names = curr_child_cp.map{|x| x[:name]}.uniq
    names.each do |name|
      curr = curr_child_cp.find { |x| x[:name] == name }
      prev = prev_child_cp.find { |x| x[:name] == name }
      next if curr == prev
      @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :update, type: :custom, name: name, previous: prev[:value], current: curr[:value]}
    end
  end

  def custom_properties_build_new(current, curr_child, curr_child_cp)
    @changes[current.identifier][:items][curr_child.identifier] = [] unless @changes[current.identifier][:items].key?(curr_child.identifier)
    names = curr_child_cp.map{|x| x[:name]}.uniq
    names.each do |name|
      curr = curr_child_cp.find { |x| x[:name] == name }
      @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :create, type: :custom, name: name, previous: "", current: curr[:value] }
    end
  end

  def item_difference(current, curr_child, prev_child)
    @changes[current.identifier][:items][curr_child.identifier] = [] unless @changes[current.identifier][:items].key?(curr_child.identifier)
    difference = curr_child.difference(prev_child)
    difference.each {|k,v| @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :update, type: :property, name: k, previous: v[:previous], current: v[:current] } if !v.is_a?(Array) && v.key?(:status) && v[:status] == :updated }
    pt = difference.dig(:preferred_term, :label)
    @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :update, type: :preferred_term, name: :preferred_term, previous: pt[:previous], current: pt[:current] } if !pt.nil? && pt[:status] == :updated
    prev_syn = prev_child.synonyms_to_a
    curr_syn = curr_child.synonyms_to_a
    synonyms_created = curr_syn - prev_syn
    synonyms_deleted = prev_syn - curr_syn
    synonyms_created.each do |x|
      @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :create, type: :synonym, name: :synonym, previous: "", current: x }
    end
    synonyms_deleted.each do |x|
      @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :delete, type: :synonym, name: :synonym, previous: x, current: "" }
    end
  end

  def item_build_new(current, curr_child)
    @changes[current.identifier][:items][curr_child.identifier] = [] unless @changes[current.identifier][:items].key?(curr_child.identifier)
    properties = curr_child.to_h.slice(:identifier, :notation, :definition, :label, :extensible)
    properties.each {|k,v| @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :create, type: :property, name: k, previous: "", current: v }} 
    pt = curr_child.to_h.dig(:preferred_term, :label)
    @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :create, type: :preferred_term, name: :preferred_term, previous: "", current: pt } unless pt.nil?
    synonyms_created = curr_child.synonyms_to_a
    synonyms_created.each do |x|
      @changes[current.identifier][:items][curr_child.identifier] << { cli_action: :create, type: :synonym, name: :synonym, previous: "", current: x }
    end
  end

  def code_list_build_new(current)
    properties = current.to_h.slice(:identifier, :notation, :definition, :label, :extensible)
    properties.each {|k,v| @changes[current.identifier][k] = v} 
    pt = current.to_h.dig(:preferred_term, :label)
    @changes[current.identifier][:preferred_term] = pt unless pt.nil?
    synonyms_created = current.synonyms_to_a
    @changes[current.identifier][:synonyms] = []
    synonyms_created.each do |x|
      @changes[current.identifier][:synonyms] << x
    end
  end

  def item_different?(current, curr_child, prev_child)
    curr_child_cp = custom_properties_resolve!(custom_properties_remove_duplicates!(curr_child.custom_properties.name_value_pairs))
    prev_child_cp = prev_child.custom_properties.name_value_pairs
    cp_diff = curr_child_cp != prev_child_cp
    return false unless curr_child.diff?(prev_child) || cp_diff
    @changes[current.identifier] = {cl_action: :none, subsets: subsets?(current.uri), extends: extends?(current.uri), items: {}} unless @changes.key?(current.identifier)
    custom_properties_difference(current, curr_child, curr_child_cp, prev_child_cp)
    item_difference(current, curr_child, prev_child)
    true
  end

  def item_new?(current, curr_child)
    curr_child_cp = custom_properties_resolve!(custom_properties_remove_duplicates!(curr_child.custom_properties.name_value_pairs))
    @changes[current.identifier] = {cl_action: :none, subsets: subsets?(current.uri), extends: extends?(current.uri), items: {}} unless @changes.key?(current.identifier)
    custom_properties_build_new(current, curr_child, curr_child_cp)
    item_build_new(current, curr_child)
    true
  end

  def code_list_new?(current)
    @changes[current.identifier] = {cl_action: :create, subsets: subsets?(current.uri), extends: extends?(current.uri), items: {}} unless @changes.key?(current.identifier)
    code_list_build_new(current)
    true
  end

  def code_list_dump(current)
    ex = Thesaurus::ManagedConcept.find_full(current.uri, :export_paths)
    full_path = Rails.root.join "public/test/triple_store_#{ex.identifier}_#{Time.now}.yaml"
    File.open(full_path, "w+") do |f|
      f.write(ex.to_h.to_yaml)
    end
  rescue => e
    byebug
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
      current = Thesaurus::ManagedConcept.find_with_properties(x[:s])
      previous_uri = identify_previous(x[:s])
      previous = previous_uri.nil? ? nil : Thesaurus::ManagedConcept.find_full(previous_uri)

      if previous.nil?
        code_list_new?(current)
        code_list_dump(current)
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
        else
          diff = item_different?(current, curr_child, prev_child)
          results << {
            uri: curr_uri_s, 
            different: diff,
            checked: "",
            type: "Created",
            notes: "",
            warning: diff ? "" : ""
          }
        end
      end
      matched.each do |match_uri_s|
        curr_child = find_child(match_uri_s)
        prev_child = child_by_identifier(curr_child, previous) unless curr_child.nil?
        diff = item_different?(current, curr_child, prev_child)
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
    full_path = Rails.root.join "public/test/triple_store_migration_#{Time.now}.yaml"
    File.open(full_path, "w+") do |f|
      f.write(@changes.to_yaml)
    end
  end

  def flatten_changes
    results = []
    @changes.each do |cl, cl_entry|
      cl_entry[:items].each do |cli, cli_entry|
        cli_entry.each do |entry|
          record = {cl: cl, cl_action: cl_entry[:cl_action], subsets: cl_entry[:subsets], extends: cl_entry[:extends], cli: cli }
          entry.each { |k,v| record[k] = v }
          results << record
        end
      end
    end
    results
  end

  # Actual rake task
  task :draft_updates => :environment do
    items = identify_updates
    identify_summary_changes(items)
    identify_detailed_changes(items)
    display_results(flatten_changes, ["Code List", "CL Action", "Subset", "Extends", "Item", "CLI Action", "Type", "Name", "Previous", "Current" ], [0, 0, 0, 0, 0, 0, 15, 20, 50, 50])
    write_results
  end

end