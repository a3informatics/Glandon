class CdiscClsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClsController"

  def index
    @cdiscCls = CdiscCl.all
  end
  
  def compare
    
    # Get the parameters
    id = params[:id]
    newTermId = params[:newTermId]
    newTermNs = params[:newTermNs]
    oldTermId = params[:oldTermId]
    oldTermNs = params[:oldTermNs]
    
    # Get the new and old terminologies and the Code Lists
    @newCdiscTerm = CdiscTerm.find(newTermId, newTermNs, false)
    @oldCdiscTerm = CdiscTerm.find(oldTermId, oldTermNs, false)
    
    # Build the Code List Item differences. Filter if required.
    data = Array.new
    @oldCl = clisForCl(id, @oldCdiscTerm, data)   
    @newCl = clisForCl(id, @newCdiscTerm, data)
    #ConsoleLogger::log(C_CLASS_NAME,"compare","Data=" + data.to_json.to_s)
    @CliResults = buildResults(data)
    #ConsoleLogger::log(C_CLASS_NAME,"compare","CliResults=" + @CliResults.to_json.to_s)
    
    # Build the difference in the Code List info
    @ClResults = Array.new
    result = Hash.new
    result = currentCL(@oldCdiscTerm, @oldCl)
    @ClResults.push(result)
    result = compareCL(@newCdiscTerm, @oldCl, @newCl)
    @ClResults.push(result)
    if @oldCl != nil
      @title = @oldCl.label
      @identifier = @oldCl.identifier
    else
      @title = @newCl.label
      @identifier = @newCl.identifier
    end
  end
  
  def changes    
    id = params[:id]
    data = Array.new
    cdiscTerms = CdiscTerm.all()
    cdiscTerms.each do |key, ct|
    	clisForCl(id, ct, data)
    end
    @CliResults = buildResults(data)
      
    # Get the CLI object from each version of the terminology
    #data = Array.new
    #cdiscTerms = CdiscTerm.all()
  	#cdiscTerms.each do |key, ct|
    #  cdiscCl = CdiscCl.find(id, ct.namespace)
    #  temp = {:term => ct, :cl => cdiscCl}
    #  data.push(temp)        
    #end
    
    # Now compare. Note there may well be nil entries
    @ClResults = Array.new
    last = data.length - 1
  	data.each_with_index do |curr, index|
      cl = curr[:cl]
      if cl != nil
        if index == 0
          
          # Set the key parameters
          @id = cl.id
          @identifier = cl.identifier
          @title = cl.preferredTerm
           
        end 
        if index >= 1
          prev = data[index - 1]
          prevCl = prev[:cl]
          if  prevCl != nil
            result = compareCL(curr[:term], prev[:cl], cl)
          else
            result = currentCL(curr[:term], cl)
          end
        else
          result = currentCL(curr[:term], cl)
        end
        @ClResults.push(result)
      end
    end   
  end
  
  def show
    id = params[:id]
    namespace = params[:namespace]
    @cdiscCl = CdiscCl.find(id, namespace)
  end
  
private

  def this_params
    params.require(:cdisc_term).permit(:id, :namespace)
  end

  def clisForCl(id, cdiscTerm, data) 
    cdiscCl = CdiscCl.find(id, cdiscTerm.namespace)
  	if cdiscCl != nil
      clis = CdiscCl.allChildren(id, cdiscTerm.namespace)
    else
      clis = nil
    end
    temp = {:term => cdiscTerm, :cl => cdiscCl, :cli => clis}
    data.push(temp)        
    return cdiscCl
  end

  def buildResults (data)
    missing = Array.new
    results = Hash.new
    last = data.length - 1
  	data.each_with_index do |curr, index|
      version = curr[:term].version
      key = "V" + version.to_s
      missing.push(key)
      currClis = curr[:cli]
      if index >= 1
        if currClis != nil
          prev = data[index - 1]
          prevClis = prev[:cli]
          if prevClis != nil
            currClis.each do |cliId, currCli|
              if prevClis.has_key?(cliId)
                prevCli = prevClis[cliId]
                if CdiscCli.diff?(currCli, prevCli)
                  mark = "M"
                else
                  mark = "."
                end
              else
                mark = "."
              end
              if results.has_key?(cliId)
                temp = results[cliId]
                result = temp[:result]
                result[key] = mark
              else
                result = Hash.new
                missing.each do |mKey|
                  result[mKey] = ""
                end    
                result[key] = mark
                temp = Hash.new
                temp = {:cli => currCli, :result => result }
                results[cliId] = temp
              end
            end
          else
            currClis.each do |cliId, currCli|
              mark = "."
              if results.has_key?(cliId)
                temp = results[cliId]
                result = temp[:result]
                result[key] = mark
              else
                result = Hash.new
                missing.each do |mKey|
                  result[mKey] = ""
                end    
                result[key] = mark
                temp = Hash.new
                temp = {:cli => currCli, :result => result }
                results[cliId] = temp
              end
            end
          end
        end
      else
        # First item. Build an entry for every member
        if currClis != nil
          currClis.each do |cliId, currCli|
            result = Hash.new
            result[key] = "."
            temp = Hash.new
            temp = {:cli => currCli, :result => result }
            results[cliId] = temp
          end
        end
      end
    end
    
    # Run through the entire set of results and check for missing entries.
    # If any found then mark as deleted
    results.each do |clId, clEntry|
      result = clEntry[:result]
      update = false
      missing.each do |mKey|
        if !result.has_key?(mKey)
          result[mKey] = "X"
          update = true
        end
      end 
      if update
        clEntry[:result] = result
      end
    end  
    
    # Return the result
    return results
    
  end
  
  def filterResults (results, type)

    # Run through the entire set of results and check for missing entries.
    # If any found then mark as deleted
    results.each do |clId, clEntry|
      result = clEntry[:result]
      keep = false
      result.each do |mKey, value|
        if type == "UPDATE" && value == "M"
          keep = true
          break
        elsif type == "DELETE" && value == "X"
          keep = true
          break
        elsif type == "NEW" && value == ""
          keep = true
          break
        end
      end 
      if !keep
        results.delete(clId)
      end
    end  

    # Return the result
    return results
  
  end
    
  def compareCL (term, previousCl, currentCl)
    result = Hash.new
    if currentCl == nil && previousCl == nil
      result = {
        "version" => term.version, 
        "date" => term.versionLabel, 
        "identifier" => "",
        "notation" => "",
        "preferredTerm" => "",
        "synonym" => "",
        "extensible" => "",
        "definition" => "" }
    elsif currentCl == nil 
      result = {
        "version" => term.version, 
        "date" => term.versionLabel, 
        "identifier" => Diffy::Diff.new(previousCl.identifier, "").to_s(:html),
        "notation" => Diffy::Diff.new(previousCl.notation, "").to_s(:html),
        "preferredTerm" => Diffy::Diff.new(previousCl.preferredTerm, "").to_s(:html),
        "synonym" => Diffy::Diff.new(previousCl.synonym, "").to_s(:html),
        "extensible" => Diffy::Diff.new(previousCl.extensible, "").to_s(:html),
        "definition" => Diffy::Diff.new(previousCl.definition, "").to_s(:html) }
    elsif previousCl == nil 
      result = {
        "version" => term.version, 
        "date" => term.versionLabel, 
        "identifier" => Diffy::Diff.new("", currentCl.identifier).to_s(:html),
        "notation" => Diffy::Diff.new("", currentCl.notation).to_s(:html),
        "preferredTerm" => Diffy::Diff.new("", currentCl.preferredTerm).to_s(:html),
        "synonym" => Diffy::Diff.new("", currentCl.synonym).to_s(:html),
        "extensible" => Diffy::Diff.new("", currentCl.extensible).to_s(:html),
        "definition" => Diffy::Diff.new("", currentCl.definition).to_s(:html) }
    else
      result = {
        "version" => term.version, 
        "date" => term.versionLabel, 
        "identifier" => Diffy::Diff.new(previousCl.identifier, currentCl.identifier).to_s(:html),
        "notation" => Diffy::Diff.new(previousCl.notation, currentCl.notation).to_s(:html),
        "preferredTerm" => Diffy::Diff.new(previousCl.preferredTerm, currentCl.preferredTerm).to_s(:html),
        "synonym" => Diffy::Diff.new(previousCl.synonym, currentCl.synonym).to_s(:html),
        "extensible" => Diffy::Diff.new(previousCl.extensible, currentCl.extensible).to_s(:html),
        "definition" => Diffy::Diff.new(previousCl.definition, currentCl.definition).to_s(:html) }
    end
    return result
  end
  
  def currentCL (term, cl)
    result = Hash.new
    if cl == nil
      result = {
        "version" => term.version,
        "date" => term.versionLabel,
        "identifier" => "",
        "notation" => "",
        "preferredTerm" => "",
        "synonym" => "",
        "extensible" => "",
        "definition" => "" }
    else
      result = {
        "version" => term.version,
        "date" => term.versionLabel,
        "identifier" => cl.identifier,
        "notation" => cl.notation,
        "preferredTerm" => cl.preferredTerm,
        "synonym" => cl.synonym,
        "extensible" => cl.extensible,
        "definition" => cl.definition }
    end  
    return result
  end
   
end
