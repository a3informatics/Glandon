class CdiscTermsController < ApplicationController
  
  before_action :authenticate_user!
  
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

  def compare
    newId = params[:new]
    oldId = params[:old]
    data = Array.new
    @oldCdiscTerm = CdiscTerm.find(oldId)
    clsForTerm(@oldCdiscTerm, data)   
    
    #p "[CdiscTermController ][compare           ] data=" + data.to_s()
        
    @newCdiscTerm = CdiscTerm.find(newId)
    clsForTerm(@newCdiscTerm, data)

    #p "[CdiscTermController ][compare           ] data=" + data.to_s()

    @Results = buildResults(data)
  end
  
  def history
    data = Array.new
    cdiscTerms = CdiscTerm.all()
  	cdiscTerms.each do |ct|
      clsForTerm(ct, data)
    end
    @Results = buildResults(data)
  end
  
  def destroy
  end

  def show
    id = params[:id]
    @cdiscTerm = CdiscTerm.find(id)
    @cdiscTerms = CdiscTerm.allExcept(@cdiscTerm.version)
    @CdiscCls = CdiscCl.all(@cdiscTerm)
  end
  
private
  def this_params
    params.require(:cdisc_term).permit({:files => []}, :version, :date, :thesaurus_id)
  end
  
  def clsForTerm(cdiscTerm, data)
  
    cdiscCls = CdiscCl.all(cdiscTerm)
    cls = Hash.new
    cdiscCls.each do |cl|
      cls[cl.identifier] = cl
    end
    temp = {:term => cdiscTerm, :cl => cls}
    data.push(temp)        

  end

  def buildResults (data)
  
    missing = Array.new
    results = Hash.new
    last = data.length - 1
  	data.each_with_index do |curr, index|
      version = curr[:term].version
      key = "V" + version
      missing.push(key)
      
      p "[CdiscTermController ][buildResults        ] key=" + key
  
      currCls = curr[:cl]
      if index >= 1
        prev = data[index - 1]
        prevCls = prev[:cl]
        currCls.each do |clId, currCl|
          if prevCls.has_key?(clId)
            prevCl = prevCls[clId]
            if currCl.diff?(prevCl)
              mark = "M"
            else
              mark = "."
            end
          else
            mark = "."
          end
          if results.has_key?(clId)
            temp = results[clId]
            result = temp[:result]
            result[key] = mark
          else
            result = Hash.new
            missing.each do |mKey|
              result[mKey] = ""
            end    
            result[key] = mark
            temp = Hash.new
            temp = {:cl => currCl, :result => result }
            results[clId] = temp
          end
        end
      else
        currCls.each do |clId, currCl|
          #if results.has_key?(clId)
          #  temp = results[clId]
          #  result = temp[:result]
          #  result[key] = "."
          #else
            result = Hash.new
            result[key] = "."
            temp = Hash.new
            temp = {:cl => currCl, :result => result }
            results[clId] = temp
          #end
        end
      end
    end
    return results
  end

end
