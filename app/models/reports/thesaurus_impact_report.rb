class Reports::ThesaurusImpactReport

  C_CLASS_NAME = "Report::ThesaurusImpact"
  
  def create(thesaurus, results, user)
    @report = Reports::WickedCore.new
    @report.open("Terminology Impact Report", "#{thesaurus.identifier} #{thesaurus.version_label} (v#{thesaurus.semantic_version})", [], user)
    body(results)
    @report.close
    return @report.html
  end

  if Rails.env == "test"
    # Return the current HTML. Only available for testing.
    #
    # @return [String] The HTML
    def html
      return @report.html
    end
  end

private

  def body(results)
  	results.each_with_index do |(k, entry), i|
    	if !entry[:children].empty?
    		html = ""
	      if entry[:root][:type] == ThesaurusConcept::C_RDF_TYPE_URI.to_s
	      	html += "<h3>Updated Terminology Item</h3>"
	      	html += tc_root(entry[:root])
		    else
	      	html += "<h3>Impacted Item</h3>"
	      	html += item_root(entry[:root])
		    end
	    	references = entry[:children].inject([]) do |refs, x| 
	    		refs << results[x[:uri]][:root] 
	    	end
	    	html += item_references(references)
		    @report.add_to_body(html)
	  	  @report.add_page_break if i != results.size - 1
	  	end
    end
  end

  def tc_root(data)
    html = %Q{
    	<h4>Details</h4>
    	<table class=\"table table-striped table-bordered table-condensed\">
    		<thead>
    			<tr>
    				<td>Code List</td><td>Item</td><td>Submission Value</td><td>Preferred Term</td><td>Synonym</td><td>Definition</td>
      		</tr>
      	</thead>
      	<tbody>
      		<tr>
    				<td>#{data[:parentIdentifier]}</td><td>#{data[:identifier]}</td><td>#{data[:notation]}</td><td>#{data[:preferredTerm]}</td>
    					<td>#{data[:preferredTerm]}</td><td>#{data[:definition]}</td>
      		</tr>
      	</tbody> 
      </table>
    }
    return html
  end

  def item_root(data)
    html = %Q{
    	<h4>Impacted Items</h4>
    	<table class=\"table table-striped table-bordered table-condensed\">
    		<thead>
    			<tr>
    				<td>Identifier</td><td>Label</td><td>Version</td><td>Version Label</td>
      		</tr>
      	</thead>
      	<tbody>
	      	<tr>
  	  			<td>#{data[:scoped_identifier][:identifier]}</td>
  	  			<td>#{data[:label]}</td>
  	  			<td>#{data[:scoped_identifier][:semantic_version]}</td>
  	  			<td>#{data[:scoped_identifier][:version_label]}</td>
    	  	</tr>
    		</tbody> 
      </table>
    }
    return html
  end

  def item_references(references)
    return "<h4>Impacted Items</h4><p>None.</p>" if references.empty?
    html = %Q{
    	<h4>Impacted Items</h4>
    	<table class=\"table table-striped table-bordered table-condensed\">
    		<thead>
    			<tr>
    				<td>Identifier</td><td>Label</td><td>Version</td><td>Version Label</td>
      		</tr>
      	</thead>
      	<tbody>
    }
    references.each { |ref| 
    	html += %Q{
      	<tr>
    			<td>#{ref[:scoped_identifier][:identifier]}</td>
    			<td>#{ref[:label]}</td>
    			<td>#{ref[:scoped_identifier][:semantic_version]}</td>
    			<td>#{ref[:scoped_identifier][:version_label]}</td>
      	</tr>
    	}
    }
    html += %Q{  	
    		</tbody> 
      </table>
    }
    return html
  end

end