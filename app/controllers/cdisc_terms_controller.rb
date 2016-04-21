class CdiscTermsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscTermsController"
  
  def history
    authorize CdiscTerm
    @cdiscTerms = CdiscTerm.history()
  end
  
  def import
    authorize CdiscTerm
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @cdiscTerm = CdiscTerm.new
  end
  
  def load
    authorize CdiscTerm
    local_params = set_local_params
    local_params.each do |param|
      hash = CdiscTerm.create({:version=>param["version"], :date=>param["date"], :files=>param["files"]})
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if !@cdiscTerm.errors.empty?
        ConsoleLogger::log(C_CLASS_NAME,"load","Load errors=" + @cdiscTerm.errors.full_messages.to_sentence + ", Params=" + param.to_s)
      end
    end
    redirect_to backgrounds_path
  end

  def create
    authorize CdiscTerm
    hash = CdiscTerm.create(this_params)
    @cdiscTerm = hash[:object]
    @job = hash[:job]
    if @cdiscTerm.errors.empty?
      redirect_to backgrounds_path
    else
      flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
      redirect_to history_cdisc_terms_path
    end
  end
  
  def show
    authorize CdiscTerm
    id = params[:id]
    namespace = params[:namespace]
    @cdiscTerm = CdiscTerm.find(id, namespace)
    @cdiscTerms = CdiscTerm.allPrevious(@cdiscTerm.version)
  end
  
  def search
    authorize CdiscTerm, :view?
    id = params[:id]
    namespace = params[:namespace]
    @cdiscTerm = CdiscTerm.find(id, namespace, false)
  end
  
  def search2
    authorize CdiscTerm, :view?
    id = params[:id]
    namespace = params[:namespace]
    @cdiscTerm = CdiscTerm.find(id, namespace, false)
    @items = Notepad.where(user_id: current_user).find_each
  end
  
  def next
    authorize CdiscTerm, :view?
    id = params[:id]
    namespace = params[:namespace]
    @cdiscTerm = CdiscTerm.find(id, namespace, false)
    items = []
    more = true
    offset = params[:offset].to_i
    limit = params[:limit].to_i
    #ConsoleLogger::log(C_CLASS_NAME,"next","Offset=" + offset.to_s + ", limit=" + limit.to_s)  
    items = CdiscTerm.next(offset, limit, namespace)
    if items.count == 0
      more = false
    end
    results = {}
    results[:offset] = offset + items.count
    results[:limit] = limit
    results[:more] = more
    results[:data] = items
    ConsoleLogger::log(C_CLASS_NAME,"next","Offset=" + results[:offset].to_s + ", limit=" + results[:limit].to_s + ", count=" + items.count.to_s)  
    render :json => results, :status => 200
  end

  def compare
    authorize CdiscTerm, :view?
    newId = params[:newId]
    newNamespace = params[:newNamespace]
    oldId = params[:oldId]
    oldNamespace = params[:oldNamespace]
    @oldCdiscTerm = CdiscTerm.find(oldId, oldNamespace, false)
    @newCdiscTerm = CdiscTerm.find(newId, newNamespace, false)
    version_hash = {:new_version => @newCdiscTerm.version.to_s, :old_version => @oldCdiscTerm.version.to_s}
    @results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, version_hash)
  end
  
  def compareCalc
    authorize CdiscTerm, :view?
    
    # Get the two terminology versions
    newId = params[:newId]
    newNamespace = params[:newNamespace]
    oldId = params[:oldId]
    oldNamespace = params[:oldNamespace]
    oldCdiscTerm = CdiscTerm.find(oldId, oldNamespace, false)
    newCdiscTerm = CdiscTerm.find(newId, newNamespace, false)
    
    # If results already prepared redirect, else calculate.
    version_hash = {:new_version => newCdiscTerm.version.to_s, :old_version => oldCdiscTerm.version.to_s}
    if CdiscCtChanges.exists?(CdiscCtChanges::C_TWO_CT, version_hash)
      redirect_to compare_cdisc_terms_path(params)
    else
      hash = CdiscTerm.compare(oldCdiscTerm, newCdiscTerm)
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if @cdiscTerm.errors.empty?
        redirect_to backgrounds_path
      else
        flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
        redirect_to history_cdisc_terms_path
      end
    end
  end

  def changes
    authorize CdiscTerm, :view?
    ct = CdiscTerm.current
    @identifier = ct.identifier
    @results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
  end

  def changes_report
    authorize CdiscTerm, :view?
    @results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    pdf = Reports::CdiscChangesReport.new(@results, current_user)
    send_data pdf.render, filename: 'cdisc_changes.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def changesCalc
    authorize CdiscTerm, :view?
    if CdiscCtChanges.exists?(CdiscCtChanges::C_ALL_CT)
        redirect_to changes_cdisc_terms_path
    else
      hash = CdiscTerm.changes()
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if @cdiscTerm.errors.empty?
        redirect_to backgrounds_path
      else
        flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
        redirect_to history_cdisc_terms_path
      end
    end
  end

  def submission
    authorize CdiscTerm, :view?
    @results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
  end

  def submissionCalc
    authorize CdiscTerm, :view?
    if CdiscCtChanges.exists?(CdiscCtChanges::C_ALL_SUB)
        redirect_to submission_cdisc_terms_path
    else
      hash = CdiscTerm.submission_changes
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if @cdiscTerm.errors.empty?
        redirect_to backgrounds_path
      else
        flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
        redirect_to history_cdisc_terms_path
      end
    end
  end

  def submission_report
    authorize CdiscTerm, :view?
    @results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    pdf = Reports::CdiscSubmissionReport.new(@results, current_user)
    send_data pdf.render, filename: 'cdisc_submission.pdf', type: 'application/pdf', disposition: 'inline'
  end

  def impact
    authorize CdiscTerm, :view?
    @new_cdisc_term = CdiscTerm.find_only(params[:new_id], params[:new_ns])
    @old_cdisc_term = CdiscTerm.find_only(params[:old_id], params[:old_ns])
    @new_version = params[:new_version]
    @old_version = params[:old_version]
    @results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT_IMPACT, params)
  end

  def impact_calc
    authorize CdiscTerm, :view?
    # If results already prepared redirect, else calculate.
    if CdiscCtChanges.exists?(CdiscCtChanges::C_TWO_CT_IMPACT, params)
      redirect_to impact_cdisc_terms_path(params)
    else
      hash = CdiscTerm.impact(params)
      @cdiscTerm = hash[:object]
      @job = hash[:job]
      if @cdiscTerm.errors.empty?
        redirect_to backgrounds_path
      else
        flash[:error] = @cdiscTerm.errors.full_messages.to_sentence
        redirect_to history_cdisc_terms_path
      end
    end
  end

  def impact_report
    authorize CdiscTerm, :view?
    @results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT_IMPACT, params)
    pdf = Reports::CdiscImpactReport.new(@results, current_user)
    send_data pdf.render, filename: 'cdisc_impact.pdf', type: 'application/pdf', disposition: 'inline'
  end

private

  def this_params
    params.require(:cdisc_term).permit(:version, :date, :term, :textSearch, :cCodeSearch, :files => [] )
  end
  
  def clsForTerm(cdiscTerm, data)  
    cdiscCls = CdiscCl.allTopLevel(cdiscTerm.id, cdiscTerm.namespace)
    temp = {:term => cdiscTerm, :cls => cdiscCls}
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
                if CdiscCl.diff?(currCl, prevCl)
                  mark = "M"
                else
                  #if currCl.diff?(prevCl)
                  #  mark = "M"
                  #else
                    mark = "."
                  #end
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
                clEntry = {:cl => currCl, :result => result }
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
            clEntry = {:cl => currCl, :result => result }
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

  def set_local_params
    json = JSON.parse(IO.read("/Users/daveih/Documents/Rails/Glandon/public/upload/cdiscImportManifest.json"))
    return json
  end

end
