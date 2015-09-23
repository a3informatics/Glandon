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

  def destroy
  end

  def show
    @cdiscTerm = CdiscTerm.find(params[:id])
    ns = @cdiscTerm.namespace
    @CLs = ThesaurusConcept.allWithNs(ns)
  end
  
  private
    def this_params
      params.require(:cdisc_term).permit({:files => []}, :version, :date, :thesaurus_id)
    end

end
