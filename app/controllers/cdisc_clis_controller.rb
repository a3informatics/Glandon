require "diffy"

class CdiscClisController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @cdiscClis = CdiscCli.all
  end
  
  def new
  end
  
  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def compare
    
    id = params[:id]
    newId = params[:new]
    oldId = params[:old]
    
    p "Compare n=" + newId + ", o=" + oldId
    
    nCT = CdiscTerm.find(newId)
    oCT = CdiscTerm.find(oldId)
    nCli = CdiscCli.find(id, nCT)
    oCli = CdiscCli.find(id, oCT)    
    
    @Results = Array.new
    result = Hash.new
    result = {
      "version" => nCT.version, 
      "date" => nCT.date, 
      "identifier" => Diffy::Diff.new(oCli.identifier, nCli.identifier).to_s(:html),
      "notation" => Diffy::Diff.new(oCli.notation, nCli.notation).to_s(:html),
      "preferredTerm" => Diffy::Diff.new(oCli.preferredTerm, nCli.preferredTerm).to_s(:html),
      "synonym" => Diffy::Diff.new(oCli.synonym, nCli.synonym).to_s(:html),
      "definition" => Diffy::Diff.new(oCli.definition, nCli.definition).to_s(:html)
    }
    @Results.push(result)
    result = {
      "version" => oCT.version,
      "date" => oCT.date,
      "identifier" => oCli.identifier,
      "notation" => oCli.notation,
      "preferredTerm" => oCli.preferredTerm,
      "synonym" => oCli.synonym,
      "definition" => oCli.definition    
    }
    @Results.push(result)
    @Cli = nCli.identifier
    
  end
  
  def history

    id = params[:id]
    
    data = Array.new
    cdiscTerms = CdiscTerm.all()
  	cdiscTerms.each do |ct|
      cdiscCli = CdiscCli.find(id, ct)
      temp = {:term => ct, :cli => cdiscCli}
      data.push(temp)        
    end
    
    @Results = Array.new
    last = data.length - 1
  	data.each_with_index do |curr, index|

      @Cli = curr[:cli].identifier
    
      result = Hash.new
      if index < last
        old = data[index + 1]
        result = {
          "version" => old[:term].version, 
          "date" => old[:term].date, 
          "identifier" => Diffy::Diff.new(old[:cli].identifier, curr[:cli].identifier).to_s(:html),
          "notation" => Diffy::Diff.new(old[:cli].notation, curr[:cli].notation).to_s(:html),
          "preferredTerm" => Diffy::Diff.new(old[:cli].preferredTerm, curr[:cli].preferredTerm).to_s(:html),
          "synonym" => Diffy::Diff.new(old[:cli].synonym, curr[:cli].synonym).to_s(:html),
          "definition" => Diffy::Diff.new(old[:cli].definition, curr[:cli].definition).to_s(:html)
        }
      else
        result = {
          "version" => curr[:term].version,
          "date" => curr[:term].date,
          "identifier" => curr[:cli].identifier,
          "notation" => curr[:cli].notation,
          "preferredTerm" => curr[:cli].preferredTerm,
          "synonym" => curr[:cli].synonym,
          "definition" => curr[:cli].definition    
        }
      end
      @Results.push(result)
    end
    
    p "Results=" + @Results.to_s
    
  end
  
  def show
    id = params[:id]
    termId = params[:termId]
    @cdiscTerm = CdiscTerm.find(params[:termId])
    @cdiscTerms = CdiscTerm.allExcept(@cdiscTerm.version)
    @cdiscCli = CdiscCli.find(id, @cdiscTerm)
  end
  
  private
    def this_params
      params.require(:cdisc_term).permit(:id, :termId)
    end

end
