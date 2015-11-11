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
    result = currentCLI(oCT, oCli)
    @Results.push(result)
    result = compareCLI(nCT, oCli, nCli)
    @Results.push(result)
    
    # Set the key parameters
    @id = oCli.id
    @identifier = oCli.identifier
    @title = oCli.preferredTerm

    
  end
  
  def history

    # Get the identifier for the CLI
    id = params[:id]
    
    # Get the CLI object from each version of the terminology
    data = Array.new
    cdiscTerms = CdiscTerm.all()
  	cdiscTerms.each do |ct|
      cdiscCli = CdiscCli.find(id, ct)
      temp = {:term => ct, :cli => cdiscCli}
      data.push(temp)        
    end
    
    # Now compare. Note there may well be nil entries
    @Results = Array.new
    last = data.length - 1
  	data.each_with_index do |curr, index|
      cli = curr[:cli]
      if cli != nil
        if index == 0
          # Set the key parameters
          @id = cli.id
          @identifier = cli.identifier
          @title = cli.preferredTerm
        end 
        if index >= 1
          prev = data[index - 1]
          prevCli = prev[:cli]
          if  prevCli != nil
            result = compareCLI(curr[:term], prev[:cli], cli)
          else
            result = currentCLI(curr[:term], cli)
          end
        else
          result = currentCLI(curr[:term], cli)
        end
        @Results.push(result)
      end
    end
    
    p "Results=" + @Results.to_s
    
  end
  
  def show
    id = params[:id]
    termId = params[:termId]
    @cdiscTerm = CdiscTerm.find(params[:termId])
    @cdiscTerms = CdiscTerm.allPrevious(@cdiscTerm.version)
    @cdiscCli = CdiscCli.find(id, @cdiscTerm)
  end
  
private

    def this_params
      params.require(:cdisc_term).permit(:id, :termId)
    end

    def compareCLI (term, previousCli, currentCli)
      result = Hash.new
      result = {
        "version" => term.internalVersion, 
        "date" => term.version, 
        "identifier" => Diffy::Diff.new(previousCli.identifier, currentCli.identifier).to_s(:html),
        "notation" => Diffy::Diff.new(previousCli.notation, currentCli.notation).to_s(:html),
        "preferredTerm" => Diffy::Diff.new(previousCli.preferredTerm, currentCli.preferredTerm).to_s(:html),
        "synonym" => Diffy::Diff.new(previousCli.synonym, currentCli.synonym).to_s(:html),
        "definition" => Diffy::Diff.new(previousCli.definition, currentCli.definition).to_s(:html) }
      return result
    end
    
    def currentCLI (term, cli)
      result = Hash.new
      result = {
        "version" => term.internalVersion,
        "date" => term.version,
        "identifier" => cli.identifier,
        "notation" => cli.notation,
        "preferredTerm" => cli.preferredTerm,
        "synonym" => cli.synonym,
        "definition" => cli.definition }
      return result
    end
      
end
