require 'rails_helper'

describe ApplicationController, type: :controller do

  describe "helper tests" do

    describe "to turtle"

    describe "before_action_steps"
    
    describe "get_token(mi)"

    describe "edit_item(item)"
    
    describe "after_sign_out_path_for(*)"

    it "protect from bad id" do
      expect(Uri).to receive(:safe_id?).and_return(true)
      expect(controller.protect_from_bad_id({id: "xxx"})).to eq("xxx")
      expect(Uri).to receive(:safe_id?).and_return(false)
      expect{controller.protect_from_bad_id({id: "xxx"})}.to raise_error(Errors::ApplicationLogicError, "Possible threat from bad id detected xxx.")
    end

    it "path for" do
      expect{controller.path_for(:action, Fuseki::Base.new)}.to raise_error(Errors::ApplicationLogicError, "Generic path_for method called. Controllers should overload.")
    end

  end
  
end


