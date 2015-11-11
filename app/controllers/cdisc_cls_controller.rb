class CdiscClsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @cdiscCls = CdiscCl.all
  end
  
  def new
  end
  
  def create
  end

  def update
  end

  def edit
  end

  def compare
    
    # Get the parameters
    type = params[:type]
    id = params[:id]
    newId = params[:new]
    oldId = params[:old]
    
    # Get the new and old terminologies and the Code Lists
    nCT = CdiscTerm.find(newId)
    nCl = CdiscCl.find(id, nCT)
    oCT = CdiscTerm.find(oldId)
    oCl = CdiscCl.find(id, oCT)    

    # Build the Code List Item differences. Filter if required.
    data = Array.new
    clisForCl(id, nCT, data)
    clisForCl(id, oCT, data)   
    @CliResults = buildResults(data)
    if type != "ALL"
      @CliResults = filterResults(@CliResults, type)
    end

    # Build the difference in the Code List info
    @ClResults = Array.new
    result = Hash.new
    result = currentCL(oCT, oCl)
    @ClResults.push(result)
    result = compareCL(nCT, oCl, nCl)
    @ClResults.push(result)
    
    # Set the key parameters
    @id = oCl.id
    @identifier = oCl.identifier
    @title = oCl.preferredTerm
    
  end
  
  def history
    
    id = params[:id]
    data = Array.new
    cdiscTerms = CdiscTerm.all()
    cdiscTerms.each do |ct|
    	clisForCl(id, ct, data)
    end
    @CliResults = buildResults(data)
      
    # Get the CLI object from each version of the terminology
    data = Array.new
    cdiscTerms = CdiscTerm.all()
  	cdiscTerms.each do |ct|
      cdiscCl = CdiscCl.find(id, ct)
      temp = {:term => ct, :cl => cdiscCl}
      data.push(temp)        
    end
    
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
  
  def destroy
  end

  def show
    id = params[:id]
    termId = params[:termId]
    @cdiscTerm = CdiscTerm.find(params[:termId])
    @cdiscTerms = CdiscTerm.allPrevious(@cdiscTerm.version)
    @cdiscCl = CdiscCl.find(id, @cdiscTerm)
    @cdiscClis = CdiscCli.allForCl(id, @cdiscTerm)
  end
  
private

  def this_params
    params.require(:cdisc_term).permit(:id, :termId)
  end

  def clisForCl(id, cdiscTerm, data)
  
    cdiscCl = CdiscCl.find(id, cdiscTerm)
  	if cdiscCl != nil
      if @cdiscCl == nil
        @cdiscCl = cdiscCl
      end
      clis = CdiscCli.allForCl(id, cdiscTerm)
    else
      clis = nil
    end
    temp = {:term => cdiscTerm, :cl => cdiscCl, :cli => clis}
    data.push(temp)        

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
                if currCli.diff?(prevCli)
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
    result = {
      "version" => term.internalVersion, 
      "date" => term.version, 
      "identifier" => Diffy::Diff.new(previousCl.identifier, currentCl.identifier).to_s(:html),
      "notation" => Diffy::Diff.new(previousCl.notation, currentCl.notation).to_s(:html),
      "preferredTerm" => Diffy::Diff.new(previousCl.preferredTerm, currentCl.preferredTerm).to_s(:html),
      "synonym" => Diffy::Diff.new(previousCl.synonym, currentCl.synonym).to_s(:html),
      "extensible" => Diffy::Diff.new(previousCl.extensible, currentCl.extensible).to_s(:html),
      "definition" => Diffy::Diff.new(previousCl.definition, currentCl.definition).to_s(:html) }
    return result
  end
  
  def currentCL (term, cl)
    result = Hash.new
    result = {
      "version" => term.internalVersion,
      "date" => term.version,
      "identifier" => cl.identifier,
      "notation" => cl.notation,
      "preferredTerm" => cl.preferredTerm,
      "synonym" => cl.synonym,
      "extensible" => cl.extensible,
      "definition" => cl.definition }
    return result
  end
   
end
