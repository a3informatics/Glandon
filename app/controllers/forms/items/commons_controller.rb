require 'controller_helpers.rb'

class Forms::Items::CommonsController < ManagedItemsController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::CommonsController"

  include ControllerHelpers


private

  def model_klass
    Form
  end

end
