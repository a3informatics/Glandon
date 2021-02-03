require 'rails_helper'

describe TokenSet do

  include DataHelpers
	include PauseHelpers
  include UserAccountHelpers
  include IsoManagedFactory

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    @user = ua_add_user(email: "token_user_1@example.com")
    @user_other = ua_add_user(email: "token_user_2@example.com")
    Token.destroy_all
  end

  after :all do
    ua_remove_user("token_user_1@example.com")
    ua_remove_user("token_user_2@example.com")
    Token.destroy_all
  end

	it "allows set to be set" do
    items = []
  	["1", "2", "3"].each { |x| items << create_iso_managed("ITEM #{x}", "Item #{x}") }
  	token_set = TokenSet.new(items, @user)
    expect(token_set.items.count).to eq(3)
    expect(token_set.locked?).to eq(true)
    expect(token_set.items[0][:item].uri.to_s).to eq("http://www.acme-pharma.com/ITEM_1/V1")
    expect(token_set.items[1][:item].uri.to_s).to eq("http://www.acme-pharma.com/ITEM_2/V1")
    expect(token_set.items[2][:item].uri.to_s).to eq("http://www.acme-pharma.com/ITEM_3/V1")
    expect(Token.all.count).to eq(3)
  end

  it "allows set to be released" do
    items = []
    ["4", "5", "6"].each { |x| items << create_iso_managed("ITEM #{x}", "Item #{x}") }
    token_set = TokenSet.new(items, @user)
    expect(token_set.items.count).to eq(3)
    expect(Token.all.count).to eq(3)
    token_set.release
    expect(token_set.items.count).to eq(0)
    expect(Token.all.count).to eq(0)
  end

  it "enumerates" do
    expected = ["http://www.acme-pharma.com/ITEM_7/V1", "http://www.acme-pharma.com/ITEM_8/V1", "http://www.acme-pharma.com/ITEM_9/V1"]
    items = []
    ["7", "8", "9"].each { |x| items << create_iso_managed("ITEM #{x}", "Item #{x}") }
    token_set = TokenSet.new(items, @user)
    index = 0
    token_set.each { |item| expect(item[:item].uri.to_s).to eq(expected[index]); index += 1}
  end

  it "add item" do
    expected = ["http://www.acme-pharma.com/ITEM_10/V1", "http://www.acme-pharma.com/ITEM_11/V1", "http://www.acme-pharma.com/ITEM_12/V1"]
    items = []
    ["10", "11", "12"].each { |x| items << create_iso_managed("ITEM #{x}", "Item #{x}") }
    token_set = TokenSet.new(items[0..1], @user)
    expect(token_set.items.count).to eq(2)
    expect(token_set.locked?).to eq(true)
    token_set << items[2]
    expect(token_set.items.count).to eq(3)
    expect(token_set.locked?).to eq(true)
    index = 0
    token_set.each { |item| expect(item[:item].uri.to_s).to eq(expected[index]); index += 1}
  end

  it "determine if everything is locked" do
    items = []
    ["20", "21"].each { |x| items << create_iso_managed("ITEM #{x}", "Item #{x}") }
    Token.obtain(items[0], @user_other)
    token_set = TokenSet.new(items, @user)
    expect(token_set.items.count).to eq(2)
    expect(token_set.locked?).to eq(false)
  end

  it "set of ids" do
    items = []
    ["30", "31"].each { |x| items << create_iso_managed("ITEM #{x}", "Item #{x}") }
    token_set = TokenSet.new(items, @user)
    expect(token_set.ids).to eq([items[0].id, items[1].id])
  end

  it "set of uris" do
    items = []
    ["40", "41"].each { |x| items << create_iso_managed("ITEM #{x}", "Item #{x}") }
    token_set = TokenSet.new(items, @user)
    expect(token_set.uris.map{|x| x.to_s}).to match_array([items[0].uri.to_s, items[1].uri.to_s])
  end

end
