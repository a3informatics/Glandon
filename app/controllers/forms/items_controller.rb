class Forms::ItemsController < ApplicationController
  
  before_action :authenticate_user!
  
  #def index
  #  authorize Form::Item
  #  @formItems = Form::Item.all
  #end
  
  def show 
    authorize Form::Item
    @form = Form.find(params[:formId], params[:namespace], false)
    type = IsoConcept.get_type(params[:id], params[:namespace])
    if type.to_s == Form::Item::BcProperty::C_RDF_TYPE_URI.to_s
      @formItem = Form::Item::BcProperty.find(params[:id], params[:namespace])
    elsif type.to_s == Form::Item::Question::C_RDF_TYPE_URI.to_s
      @formItem = Form::Item::Question.find(params[:id], params[:namespace])
    elsif type.to_s == Form::Item::Placeholder::C_RDF_TYPE_URI.to_s
      @formItem = Form::Item::Placeholder.find(params[:id], params[:namespace])
    elsif type.to_s == Form::Item::mapping::C_RDF_TYPE_URI.to_s
      @formItem = Form::Item::Mapping.find(params[:id], params[:namespace])
    else
      @formItem = Form::Item::TextLabel.find(params[:id], params[:namespace])
    end
    @property = @formItem.bc_property
    @tcs = @formItem.thesaurus_concepts
  end
  
private

  def the_params
    params.require(:form_item_group).permit()
  end  

end
