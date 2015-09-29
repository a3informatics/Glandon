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
    
    id = params[:id]
    newId = params[:new]
    oldId = params[:old]
    data = Array.new
    cdiscTerm = CdiscTerm.find(newId)
    clisForCl(id, cdiscTerm, data)
    cdiscTerm = CdiscTerm.find(oldId)
    clisForCl(id, cdiscTerm, data)   
    @Results = buildResults(data)
    
  end
  
  def history
    
    id = params[:id]
    data = Array.new
    cdiscTerms = CdiscTerm.all()
    cdiscTerms.each do |ct|
    	clisForCl(id, ct, data)
    end
    @Results = buildResults(data)
      
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
      if @Cl == nil
        @Cl = cdiscCl.identifier
      end
      cdiscClis = CdiscCli.allForCl(id, cdiscTerm)
      clis = Hash.new
      cdiscClis.each do |cli|
        clis[cli.identifier] = cli
      end
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
          
            # Check for any CLIs that have been deleted, add a blank entry
            # to ensure hash stays 'retangular', i.e. an entry for every CLI
            # that existed for every Version
            prevClis.each do |cliId, prevCli|
              temp = results[cliId]
              result = temp[:result]
              if !result.has_key?(key)
                result[key] = ""
                currCli = temp[:cli]
                temp = {:cli => currCli, :result => result }
                results[cliId] = temp
              end
            end
          end
        else
          #
          #
        end
      else
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
    return results
  end
    
end
