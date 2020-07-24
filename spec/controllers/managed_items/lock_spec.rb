require 'rails_helper'

describe "ManagedItemsController::Lock" do

  include DataHelpers
	include PauseHelpers
  include UserAccountHelpers

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ACME_FN000150_1.ttl"]
    load_files(schema_files, data_files)
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

	it "get token" do
    item = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/Height__Pilot_/V1#F"))
    flash =  ActionDispatch::Flash::FlashHash.new
  	lock = ManagedItemsController::Lock.new(:get, item, @user, flash)
    expect(lock.item.uri.to_s).to eq("http://www.s-cubed.dk/Height__Pilot_/V1#F")
    expect(lock.user).to eq(@user)
    expect(lock.error).to eq ("")
  end

  it "prevents another user obtaining a token when already allocated" do
    item = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/Height__Pilot_/V1#F"))
    flash = ActionDispatch::Flash::FlashHash.new
    lock1 = ManagedItemsController::Lock.new(:get, item, @user, flash)
    lock2 = ManagedItemsController::Lock.new(:get, item, @user2, flash)
    expect(lock2.token).to eq(nil)
  end

  it "allows a token to be kept" do
    item = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/Height__Pilot_/V1#F"))
    flash = ActionDispatch::Flash::FlashHash.new
    lock1 = ManagedItemsController::Lock.new(:get, item, @user, flash)
    expect(lock1.item.uri.to_s).to eq("http://www.s-cubed.dk/Height__Pilot_/V1#F")
    expect(lock1.user).to eq(@user)
    lock2 = ManagedItemsController::Lock.new(:keep, item, @user, flash)
    expect(lock2.item.uri.to_s).to eq("http://www.s-cubed.dk/Height__Pilot_/V1#F")
    expect(lock2.user).to eq(@user)
  end

  it "allows a token to be kept, error" do
    item = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/Height__Pilot_/V1#F"))
    flash = ActionDispatch::Flash::FlashHash.new
    token = Token.obtain(item, @user)
    lock = ManagedItemsController::Lock.new(:keep, item, @user2, flash)
    expect(flash[:error]).to match(/The item is locked for editing by user: token_user_1@example.com.*/)
    expect(lock.error).to eq ("The item is locked for editing by user: token_user_1@example.com.")
  end

end
