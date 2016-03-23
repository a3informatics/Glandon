class SponsorTermsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "SponsorTermsController"
  
  def index
    authorize SponsorTerm
    @sponsorTerms = SponsorTerm.all
  end
  
  def new
    authorize SponsorTerm
    @files = Dir.glob(Rails.root.join("public","upload") + "*")
    @sponsorTerm = SponsorTerm.new
  end
  
  def create
    authorize SponsorTerm
    @sponsorTerm = SponsorTerm.create(this_params)
    redirect_to sponsor_terms_path
  end

  def search
    authorize SponsorTerm
    term = params[:term]
    textSearch = params[:textSearch]
    cCodeSearch = params[:cCodeSearch]
    ConsoleLogger::log(C_CLASS_NAME,"search","Term=" + term.to_s + ", textSearch=" + textSearch.to_s + ", codeSearch=" + cCodeSearch)
    if term != "" && textSearch == "text"
      @results = SponsorTerm.searchText(term)  
    elsif term != "" && cCodeSearch == "ccode"
      @results = SponsorTerm.searchIdentifier(term)
    else
      @results = Array.new
    end
    render json: @results
  end
  
  def show
    authorize SponsorTerm
    id = params[:id]
    @sponsorTerm = SponsorTerm.find(id)
    #@sponsorCls = SponsorTerm.thesaurus.all.all(@sponsorTerm)
  end
  
private

  def this_params
    params.require(:sponsor_term).permit({:files => []}, :version, :date, :term, :textSearch, :cCodeSearch)
  end
  
end
