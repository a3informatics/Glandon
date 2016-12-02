require 'rails_helper'

RSpec.describe Token, type: :model do

  include DataHelpers
	include PauseHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  before :each do
    @user = User.create :email => "example@example.com", :password => "changeme" 
    @user.add_role :reader
  end

	it "allows a token to be obtained" do
  	item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
  	token = Token.obtain(item, @user)
    expect(token.item_uri).to eq("http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1")
    expect(token.item_info).to eq("[ACME, VS BASELINE, 1]")
    expect(token.user_id).to eq(@user.id)
    expect(token.locked_at).to be_within(1.second).of Time.now
  end

  it "prevents a token being obtained when already allocated" do
  	item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    token = Token.obtain(item, @user)
    expect(token).to eq(nil)
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

  it "determines if user owns lock" do
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    expect(Token.locked_by_user?(item, @user)).to eq(true)
  end

  it "determines if user does not own lock" do
    item = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    token = Token.obtain(item, @user)
    token.release
    expect(Token.locked_by_user?(item, @user)).to eq(false)
  end

  it "allows tokens to be expired" do
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
    expect(Token.locked_by_user?(item1, @user)).to eq(false)
    expect(Token.locked_by_user?(item2, @user)).to eq(false)
    expect(Token.locked_by_user?(item3, @user)).to eq(true)
    expect(Token.locked_by_user?(item4, @user)).to eq(true)
  end

  it "allows the timeout to be modified" do
    Token.set_timeout(10)
    expect(Token.get_timeout).to eq(10)
    item1 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item1.id = "1"
    token1 = Token.obtain(item1, @user)
    sleep 3
    expect(Token.locked_by_user?(item1, @user)).to eq(true)
    sleep 3
    expect(Token.locked_by_user?(item1, @user)).to eq(true)
    sleep 6
    expect(Token.locked_by_user?(item1, @user)).to eq(false)
    Token.set_timeout(5)
  end

end
