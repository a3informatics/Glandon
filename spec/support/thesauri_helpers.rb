module ThesauriHelpers
  
  def count_cl(th)
    query_string = %Q{
      SELECT (COUNT(DISTINCT ?s) as ?count) WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    result = query_results.by_object(:count).first.to_i
    # puts colourize("Total CL count=#{result}", "blue")
    result
  end

  def count_cli(th)
    query_string = %Q{
      SELECT (COUNT(?s) as ?count) WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference/th:narrower ?s
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    result = query_results.by_object(:count).first.to_i
    # puts colourize("Total CLI count=#{result}", "blue")
    result
  end
  
  def count_distinct_cli(th)
    query_string = %Q{
      SELECT (COUNT(DISTINCT ?s) as ?count) WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference/th:narrower ?s
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    result = query_results.by_object(:count).first.to_i
    # puts colourize("Total Distinct CLI count=#{result}", "blue")
    result
  end
  
  def cl_list(th)
    query_string = %Q{
      SELECT ?cid WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
        ?s th:identifier ?cid .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    query_results.by_object_set([:cid]).map{|x| x[:cid]}
  end

  def cl_list_uri(th)
    query_string = %Q{
      SELECT ?s WHERE 
      {
        #{th.uri.to_ref} th:isTopConceptReference/bo:reference ?s .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo]) 
    query_results.by_object(:s)
  end

  def check_thesaurus_concept_actual_expected(actual, sub_dir, filename, args={})
    synonyms = []
    write_file = args[:write_file] ? args[:write_file] : false
    fill_out(actual)
    if write_file
      puts colourize("***** WARNING: Writing Results File *****", "red")
      write_yaml_file(actual, sub_dir, filename)
    end
    expected = read_yaml_file(sub_dir, filename)
    expect(actual).to thesauri_concept_equal(expected)   
  end

  def replace_old_reference(old_uri)
    # Except subject references such as
    # <http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71620_C41139>
    uri_s = old_uri.gsub(/(<|>)/, '')
    uri = Uri.new(uri: uri_s)
    parts = uri.fragment.dup.gsub(/CLI-/, '').split("_")
    query_string = %Q{
SELECT DISTINCT ?cli WHERE 
{ 
  <http://www.cdisc.org/CT/V59#TH> (th:isTopConceptReference/bo:reference) ?cl .
  ?cl th:identifier "#{parts.first}" .
  ?cl th:narrower ?cli .
  ?cli th:identifier "#{parts.last}" .
}}
    query_results = Sparql::Query.new.query(query_string, "", [:th, :bo])
    result = query_results.by_object_set([:cli]).first[:cli]
    # puts "Previous URI: #{uri_s} translated to Current URI: #{result}"
    result
  end

  def self.fake_extended(uri, ext_id)
    sparql = %Q{INSERT DATA
      { 
        <http://example/extended-#{ext_id}> <http://www.assero.co.uk/Thesaurus#extends> #{uri.to_ref} .
      }
    }
    Sparql::Update.new.sparql_update(sparql, "", []) 
  end

  def self.fake_subsetted(uri, ext_id)
    sparql = %Q{INSERT DATA
      { 
        <http://example/extended-#{ext_id}> <http://www.assero.co.uk/Thesaurus#subsets> #{uri.to_ref} .
      }
    }
    Sparql::Update.new.sparql_update(sparql, "", []) 
  end
  
private

  def fill_out(item)
    no_action = [:uri, :id, :notation, :identifier, :label, :rdf_type, :definition, :extensible, :item]
    item.each do |key, value|
      next if no_action.include? key
      if key == :synonym
        synonyms = []
        value.each do |synonym|
          if synonym.is_a?(Hash)
            synonyms << synonym
          else
            uri = Uri.from_uri_or_string(synonym)
            synonyms << Thesaurus::Synonym.find(uri).to_h
          end
          # puts colourize("Aligning Synonym #{synonyms.last[:label]}", "blue")
        end
        item[key] = synonyms
      elsif key == :preferred_term
        if !value.is_a?(Hash)
          uri = Uri.from_uri_or_string(value)
          item[key] = Thesaurus::PreferredTerm.find(uri).to_h
          # puts colourize("Aligning PT #{item[key][:label]}", "blue")
        end
      elsif key == :narrower
        narrower = []
        value.each do |x| 
          if !x.is_a?(Hash)
            uri = Uri.from_uri_or_string(x)
            narrower << fill_out(Thesaurus::UnmanagedConcept.find(uri).to_h)
          else
            narrower << fill_out(x)
          end
        end
        item[key] = narrower
      end
    end
  end

end