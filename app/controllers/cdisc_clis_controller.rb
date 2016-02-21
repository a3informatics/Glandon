require "diffy"

class CdiscClisController < ApplicationController
  
  C_CLASS_NAME = "CdiscClisController"

  before_action :authenticate_user!
  
  def index
    @cdiscClis = CdiscCli.all
  end
  
  def impact
    id = params[:id]
    namespace = params[:namespace]
    @cdiscCli = CdiscCli.find(id, namespace)
    @bcs = BiomedicalConcept.impact(params)
  end

  def show
    id = params[:id]
    namespace = params[:namespace]
    @cdiscCli = CdiscCli.find(id, namespace)
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
    @newCli = CdiscCli.find(id, newTermNs)
    @oldCdiscTerm = CdiscTerm.find(oldTermId, oldTermNs, false)
    @oldCli = CdiscCli.find(id, oldTermNs)    
    #ConsoleLogger::log(C_CLASS_NAME,"compare","P=" + @oldCli.to_json.to_s + ", C=" + @newCli.to_json.to_s)
      
    @Results = Array.new
    result = Hash.new
    result = currentCLI(@oldCdiscTerm, @oldCli)
    @Results.push(result)
    result = compareCLI(@newCdiscTerm, @oldCli, @newCli)
    @Results.push(result)
    if @oldCli != nil
      @title = @oldCli.preferredTerm
      @identifier = @oldCli.identifier
    else
      @title = @newCli.preferredTerm
      @identifier = @newCli.identifier
    end
  end
  
  def changes
    id = params[:id]
    data = Array.new
    cdiscTerms = CdiscTerm.all()
  	cdiscTerms.each do |key, ct|
      cdiscCli = CdiscCli.find(id, ct.namespace)
      temp = {:term => ct, :cli => cdiscCli}
      data.push(temp)        
    end
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
  end
    
private

    def this_params
      params.require(:cdisc_term).permit(:id, :namespace)
    end

    def compareCLI (term, previousCli, currentCli)
      #ConsoleLogger::log(C_CLASS_NAME,"compareCLI","P=" + previousCli.to_json.to_s + ", C=" + currentCli.to_json.to_s)
      result = Hash.new
      if currentCli == nil && previousCli == nil
        result = {
          "version" => term.version, 
          "date" => term.versionLabel, 
          "identifier" => "",
          "notation" => "",
          "preferredTerm" => "",
          "synonym" => "",
          "definition" => "" }
      elsif currentCli == nil 
        result = {
          "version" => term.version, 
          "date" => term.versionLabel, 
          "identifier" => Diffy::Diff.new(previousCli.identifier, "").to_s(:html),
          "notation" => Diffy::Diff.new(previousCli.notation, "").to_s(:html),
          "preferredTerm" => Diffy::Diff.new(previousCli.preferredTerm, "").to_s(:html),
          "synonym" => Diffy::Diff.new(previousCli.synonym, "").to_s(:html),
          "definition" => Diffy::Diff.new(previousCli.definition, "").to_s(:html) }
      elsif previousCli == nil 
        result = {
          "version" => term.version, 
          "date" => term.versionLabel, 
          "identifier" => Diffy::Diff.new("", currentCli.identifier).to_s(:html),
          "notation" => Diffy::Diff.new("", currentCli.notation).to_s(:html),
          "preferredTerm" => Diffy::Diff.new("", currentCli.preferredTerm).to_s(:html),
          "synonym" => Diffy::Diff.new("", currentCli.synonym).to_s(:html),
          "definition" => Diffy::Diff.new("", currentCli.definition).to_s(:html) }
      else
        result = {
          "version" => term.version, 
          "date" => term.versionLabel, 
          "identifier" => Diffy::Diff.new(previousCli.identifier, currentCli.identifier).to_s(:html),
          "notation" => Diffy::Diff.new(previousCli.notation, currentCli.notation).to_s(:html),
          "preferredTerm" => Diffy::Diff.new(previousCli.preferredTerm, currentCli.preferredTerm).to_s(:html),
          "synonym" => Diffy::Diff.new(previousCli.synonym, currentCli.synonym).to_s(:html),
          "definition" => Diffy::Diff.new(previousCli.definition, currentCli.definition).to_s(:html) }
      end
      return result
    end
    
    def currentCLI (term, cli)
      result = Hash.new
      if cli == nil
        result = {
          "version" => term.version,
          "date" => term.versionLabel,
          "identifier" => "",
          "notation" => "",
          "preferredTerm" => "",
          "synonym" => "",
          "definition" => "" }
      else
        result = {
          "version" => term.version,
          "date" => term.versionLabel,
          "identifier" => cli.identifier,
          "notation" => cli.notation,
          "preferredTerm" => cli.preferredTerm,
          "synonym" => cli.synonym,
          "definition" => cli.definition }
      end
      return result
    end
      
end
