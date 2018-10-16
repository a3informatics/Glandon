class Imports::TermsController < Imports::BaseController
  
  def new
    @th = []
    Thesaurus.all.each { |t| @th << t if t.registrationStatus == :Incomplete.to_s }
    super
  end

private
 
  def the_params
    super([:uri])
  end

end
