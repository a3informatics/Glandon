require 'rails_helper'

describe "Token" do

  include DataHelpers
	include PauseHelpers
  include UserAccountHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_token_object
    @user = ua_add_user(email: "token_user_1@example.com")
    @user.add_role :reader
    @user2 = ua_add_user(email: "token_user_2@example.com")
    @user2.add_role :reader
  end

  after :all do
    ua_remove_user("token_user_1@example.com")
    ua_remove_user("token_user_2@example.com")
    Token.restore_timeout
  end

	it "allows a token to be obtained" do
  	item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  	token = Token.obtain(item, @user)
    expect(token.item_uri).to eq("http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1")
    expect(token.item_info).to eq("[ACME, VS BASELINE, 1]")
    expect(token.user_id).to eq(@user.id)
    expect(token.locked_at).to be_within(1.second).of Time.now
  end

  it "allows the same user to obtain a token when already allocated" do
  	Token.set_timeout(5)
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token1 = Token.obtain(item, @user)
    sleep 3 # Valid sleep in this case, to let token 1 elapse a bit so as to test reset
    token2 = Token.obtain(item, @user)
    expect(token1.item_uri).to eq(token2.item_uri) # Same item locked
    expect(token2.locked_at).to be_within(1.second).of Time.now # time reset to maximise lock time
  end

  it "prevents another user obtaining a token when already allocated" do
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token1 = Token.obtain(item, @user)
    token2 = Token.obtain(item, @user2)
    expect(token2).to eq(nil)
  end

  it "allows a token to be released" do
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    token.release
    expect{Token.find(token.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "allows a token to be refreshed" do
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    sleep 3
    expect(token.refresh).to eq(1)
    expect(token.locked_at).to be_within(1.second).of Time.now
    sleep 5
    expect(token.refresh).to eq(2)
    expect(token.locked_at).to be_within(1.second).of Time.now
  end

  it "find token" do
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    expect(Token.find_token(item, @user).to_json).to eq(token.to_json)
  end

  it "find token, released" do
    Token.set_timeout(5)
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    sleep 6
    expect(Token.find_token(item, @user)).to eq(nil)
  end

  it "find token for item" do
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    expect(Token.find_token_for_item(item).to_json).to eq(token.to_json)
  end

  it "find token for item, released" do
    Token.set_timeout(5)
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    sleep 6
    expect(Token.find_token_for_item(item)).to eq(nil)
  end

  it "find token for item, no token" do
    Token.set_timeout(5)
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(Token.find_token_for_item(item)).to eq(nil)
  end

  it "determines if user does not own lock, never locked" do
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(Token.find_token(item, @user)).to eq(nil)
  end

  it "allows tokens to be expired" do
    Token.set_timeout(5)
    item1 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item1.id = "1"
    item2 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item2.id = "2"
    item3 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item3.id = "3"
    item4 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item4.id = "4"
    token1 = Token.obtain(item1, @user)
    token2 = Token.obtain(item2, @user)
    sleep 3
    token3 = Token.obtain(item3, @user)
    token4 = Token.obtain(item4, @user)
    sleep 3
    expect(Token.find_token(item1, @user)).to eq(nil)
    expect(Token.find_token(item2, @user)).to eq(nil)
    expect(Token.find_token(item3, @user).to_json).to eq(token3.to_json)
    expect(Token.find_token(item4, @user).to_json).to eq(token4.to_json)
  end

  it "allows the timeout to be modified" do
    Token.set_timeout(10)
    expect(Token.get_timeout).to eq(10)
    item1 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item1.id = "1"
    token1 = Token.obtain(item1, @user)
    sleep 3
    expect(Token.find_token(item1, @user).to_json).to eq(token1.to_json)
    sleep 3
    expect(Token.find_token(item1, @user).to_json).to eq(token1.to_json)
    sleep 6
    expect(Token.find_token(item1, @user)).to eq(nil)
    Token.set_timeout(5)
  end

  it "allows the timeout to be restored" do
    Token.restore_timeout
    expect(Token.get_timeout).to eq(ENV['token_timeout'].to_i)
    Token.set_timeout(10)
    expect(Token.get_timeout).to eq(10)
    Token.restore_timeout
    expect(Token.get_timeout).to eq(ENV['token_timeout'].to_i)
    Token.set_timeout(15)
    expect(Token.get_timeout).to eq(15)
    Token.restore_timeout
    expect(Token.get_timeout).to eq(ENV['token_timeout'].to_i)
    Token.set_timeout(5)
  end

  it "tests for an expired timeout" do
    Token.set_timeout(5)
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    expect(token.timed_out?).to eq(false)
    sleep 6
    expect(token.timed_out?).to eq(true)
  end

  it "tests for the remaining time" do
    Token.set_timeout(5)
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    expect(token.remaining).to eq(5)
    sleep 1
    expect(token.remaining).to eq(4)
    sleep 1
    expect(token.remaining).to eq(3)
  end

  it "allows the timeout to be extended" do
    Token.set_timeout(5)
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    sleep 3
    token.extend_token
    sleep 4
    expect(token.timed_out?).to eq(false)
  end

end
