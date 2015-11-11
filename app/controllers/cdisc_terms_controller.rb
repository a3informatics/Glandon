class CdiscTermsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscTermsController"
  
  def index
    @cdiscTerms = CdiscTerm.all
  end
  
  def new
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @cdiscTerm = CdiscTerm.new
  end
  
  def create
    @cdiscTerm = CdiscTerm.create(this_params)
    redirect_to cdisc_terms_path
  end

  def update
  end

  def edit
  end

  def search
    term = params[:term]
    textSearch = params[:textSearch]
    cCodeSearch = params[:cCodeSearch]
    ConsoleLogger::log(C_CLASS_NAME,"search","Term=" + term.to_s + ", textSearch=" + textSearch.to_s + ", codeSearch=" + cCodeSearch)
    if term != "" && textSearch == "text"
      @results = CdiscTerm.searchText(term)  
    elsif term != "" && cCodeSearch == "ccode"
      @results = CdiscTerm.searchIdentifier(term)
    else
      @results = Array.new
    end
    render json: @results
  end
  
  def compare
    
    # Get the parameters
    type = params[:type]
    newId = params[:new]
    oldId = params[:old]
    
    # Create the results structure
    data = Array.new
    
    # Get the CLs for the old version
    oldCdiscTerm = CdiscTerm.find(oldId)
    clsForTerm(@oldCdiscTerm, data)   
        
    # Get the CLs for the new version
    newCdiscTerm = CdiscTerm.find(newId)
    clsForTerm(@newCdiscTerm, data)

    # And build the results. Filter if required.
    @Results = buildResults(data)
    if type != "ALL"
      @Results = filterResults(@Results, type)
    end
   
    # Set the key parameters
    @id = oldCdiscTerm.id
    @identifier = oldCdiscTerm.version
    @title = oldCdiscTerm.identifier
           
  end
  
  def history

    data = Array.new
    cdiscTerms = CdiscTerm.all()
  	cdiscTerms.each do |ct|
      clsForTerm(ct, data)
      if @id == nil

        # Set the key parameters
        @id = ct.id
        @identifier = ct.date
        @title = ct.identifier

      end
    end
    @Results = buildResults(data)

  end
  
  def destroy
  end

  def show
    id = params[:id]
    @cdiscTerm = CdiscTerm.find(id)
    @cdiscTerms = CdiscTerm.allPrevious(@cdiscTerm.version)
    @CdiscCls = CdiscCl.all(@cdiscTerm)
  end
  
private

  def this_params
    params.require(:cdisc_term).permit({:files => []}, :version, :date, :term, :textSearch, :cCodeSearch)
  end
  
  def clsForTerm(cdiscTerm, data)
  
    cdiscCls = CdiscCl.all(cdiscTerm)
    cls = Hash.new
    cdiscCls.each do |cl|
      cls[cl.identifier] = cl
    end
    temp = {:term => cdiscTerm, :cls => cls}
    data.push(temp)        

  end

  def buildResults (data)
  
    missing = Array.new
    results = Hash.new
    last = data.length - 1
  	data.each_with_index do |curr, index|
      currTerm = curr[:term]
      version = currTerm.version
      currCls = curr[:cls]
      key = "V" + version.to_s
      missing.push(key)
      if index >= 1
        if currCls != nil
          prev = data[index - 1]
          prevTerm = prev[:term]
          prevCls = prev[:cls]
          if prevCls != nil
            currCls.each do |clId, currCl|
              if prevCls.has_key?(clId)
                prevCl = prevCls[clId]
                if currCl.diff?(prevCl)
                  mark = "M"
                else
                  if cliDifference?(currTerm, currCl, prevTerm, prevCl)
                    mark = "M"
                  else
                    mark = "."
                  end
                end
              else
                mark = "."
              end
              if results.has_key?(clId)
                clEntry = results[clId]
                result = clEntry[:result]
                result[key] = mark
              else
                result = Hash.new
                missing.each do |mKey|
                  result[mKey] = ""
                end    
                result[key] = mark
                clEntry = Hash.new
                clEntry = {:id => currCl.id, :name => currCl.notation, :result => result }
                results[clId] = clEntry
              end
            end
          end
        end
      else
        
        # First item. Build an entry for every member
        if currCls != nil
           currCls.each do |clId, currCl|
            result = Hash.new
            result[key] = "."
            clEntry = Hash.new
            clEntry = {:id => currCl.id, :name => currCl.notation, :result => result }
            results[clId] = clEntry
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
    
    # Return the results
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

  end
  
  def cliDifference?(currTerm, currCl, prevTerm, prevCl)
  
    result = false
    currClis = CdiscCli.allForCl(currCl.id, currTerm)
    prevClis = CdiscCli.allForCl(prevCl.id, prevTerm)
    if currClis.length == prevClis.length
      currClis.each do |id, cli|
        if prevClis.has_key?(id)
          prevCli = prevClis[id]
          if cli.diff?(prevCli)
            result = true
            break
          end
        else
          result = true
          break
        end
      end  
    else
      result = true
    end
    return result
    
  end

end
