require 'rails_helper'

describe ApplicationController, type: :controller do

  include DataHelpers
  include UserAccountHelpers

  describe "helper tests" do

    login_curator

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user "lock@example.com"
      Token.delete_all
      Token.restore_timeout
    end

    it "to turtle"

    it "before_action_steps"
    
    it "get token, locked" do
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      token = controller.get_token(ct)
      expect(token).to_not be(nil)
      token.release
    end

    it "get token, locked" do
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      user_token = Token.obtain(ct, @lock_user)
      token = controller.get_token(ct)
      expect(token).to be(nil)
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com.*/)
      user_token.release
    end

    it "get token, locked, no user" do
      expect(Token).to receive(:obtain).and_return(nil)
      expect(Token).to receive(:find_token_for_item).and_return(nil)
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      token = controller.get_token(ct)
      expect(token).to be(nil)
      expect(flash[:error]).to match(/The item is locked for editing by user: <unknown>.*/)
    end

    it "get token, locked, no user" do
      expect(Token).to receive(:obtain).and_return(nil)
      expect(Token).to receive(:find_token_for_item).and_return(Token.new)
      expect(User).to receive(:find).and_raise(ActiveRecord::RecordNotFound.new("error"))
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      token = controller.get_token(ct)
      expect(token).to be(nil)
      expect(flash[:error]).to match(/The item is locked for editing by user: <unknown>.*/)
    end

    it "get token, not locked" do
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      token = controller.get_token(ct)
      expect(token).to_not be(nil)
    end

    it "edit item, cannot lock" do
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      expect(controller).to receive(:get_token).and_return(nil)
      expect(controller.edit_item(ct)).to eq(nil)
    end

    it "edit item, success, no new version" do
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      expect(ct).to receive(:create_next_version).and_return(ct)
      expect(controller.edit_item(ct).uri).to eq(ct.uri)
      expect(assigns(:token).item_uri).to eq(ct.uri.to_s)
    end

    it "edit item, success, new version" do
      ct_1 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      ct_2 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      expect(ct_1).to receive(:create_next_version).and_return(ct_2)
      expect(controller.edit_item(ct_1).uri).to eq(ct_2.uri)
      expect(assigns(:token).item_uri).to eq(ct_2.uri.to_s)
    end

    it "edit item, success, new version, cannot lock" do
      ct_1 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      ct_2 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      expect(ct_1).to receive(:create_next_version).and_return(ct_2)
      expect(controller).to receive(:get_token).and_return(Token.obtain(ct_1, controller.current_user), nil)
      expect(controller.edit_item(ct_1)).to eq(nil)
      expect(assigns(:token)).to eq(nil)
    end

    it "after_sign_out_path_for(*)"

    it "protect from bad id" do
      expect(Uri).to receive(:safe_id?).and_return(true)
      expect(controller.protect_from_bad_id({id: "xxx"})).to eq("xxx")
      expect(Uri).to receive(:safe_id?).and_return(false)
      expect{controller.protect_from_bad_id({id: "xxx"})}.to raise_error(Errors::ApplicationLogicError, "Possible threat from bad id detected xxx.")
    end

    it "path for" do
      expect{controller.path_for(:action, Fuseki::Base.new)}.to raise_error(Errors::ApplicationLogicError, "Generic path_for method called. Controllers should overload.")
    end

    it "locked message" do
      expect(controller.token_timeout_message).to eq("The changes were not saved as the edit lock has timed out.")
    end

    it "destroy message" do
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      expect(controller.token_destroy_message(ct)).to eq("The Terminology cannot be deleted as it is locked for editing by user: <unknown>.")
      Token.obtain(ct, controller.current_user)
      expect(controller.token_destroy_message(ct)).to eq("The Terminology cannot be deleted as it is locked for editing by user: base@example.com.")
    end

  end
  
end


