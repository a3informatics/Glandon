require 'rails_helper'

describe "ManagedItemsController::Edit" do

  include DataHelpers
	include PauseHelpers
  include UserAccountHelpers

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000150.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
    load_data_file_into_triple_store("mdr_identification.ttl")
    clear_token_object
    @user = ua_add_user(email: "token_user_1@example.com")
    @user.add_role :reader
    @user2 = ua_add_user(email: "token_user_2@example.com")
    @user2.add_role :reader
    Token.delete_all
  end

  after :all do
    ua_remove_user("token_user_1@example.com")
    ua_remove_user("token_user_2@example.com")
    User.destroy_all
    Token.delete_all
    Token.restore_timeout
  end

	it "edit item, cannot lock" do
    item = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    flash = ActionDispatch::Flash::FlashHash.new
    token = Token.obtain(item, @user)
    edit = ManagedItemsController::Edit.new(item, @user2, flash)
    expect(edit.lock.token).to eq(nil)
    expect(flash[:error]).to match(/The item is locked for editing by user: token_user_1@example.com.*/)
    expect(edit.lock.error).to eq ("The item is locked for editing by user: token_user_1@example.com.")
  end

  it "edit item, success, already have lock" do
    item = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    flash = ActionDispatch::Flash::FlashHash.new
    token = Token.obtain(item, @user2)
    edit = ManagedItemsController::Edit.new(item, @user2, flash)
    expect(edit.lock.token.id).to eq(token.id)
    expect(edit.lock.error).to eq ("")
    expect(edit.lock.item.uri).to eq (item.uri)
  end

  it "edit item, success, no new version" do
    item = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
    flash = ActionDispatch::Flash::FlashHash.new
    expect(item).to receive(:create_next_version).and_return(item)
    edit = ManagedItemsController::Edit.new(item, @user, flash)
    expect(edit.lock.token).to_not eq(nil)
    expect(edit.lock.error).to eq ("")
    expect(edit.lock.item.uri).to eq (item.uri)
  end

  it "edit item, success, new version" do
    ct_1 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
    ct_2 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
    flash = ActionDispatch::Flash::FlashHash.new
    expect(ct_1).to receive(:create_next_version).and_return(ct_2)
    edit = ManagedItemsController::Edit.new(ct_1, @user, flash)
    expect(edit.lock.token).to_not eq(nil)
    expect(edit.lock.error).to eq ("")
    expect(edit.lock.item.uri).to eq (ct_2.uri)
  end

end
