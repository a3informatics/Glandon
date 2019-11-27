require 'rails_helper'

describe AuditTrail do

	include DataHelpers

	def sub_dir
    return "models"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_managed_data.ttl", "iso_managed_data_2.ttl", "iso_managed_data_3.ttl"]
    load_files(schema_files, data_files)
    # clear_triple_store
    # load_schema_file_into_triple_store("ISO11179Types.ttl")
    # load_schema_file_into_triple_store("ISO11179Identification.ttl")
    # load_schema_file_into_triple_store("ISO11179Registration.ttl")
    # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    # load_schema_file_into_triple_store("BusinessForm.ttl")
    # load_test_file_into_triple_store("iso_namespace_real.ttl")
    # load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    # load_test_file_into_triple_store("iso_managed_data.ttl")
    # load_test_file_into_triple_store("iso_managed_data_2.ttl")
    # load_test_file_into_triple_store("iso_managed_data_3.ttl")
    # clear_iso_concept_object
    load_cdisc_term_versions(1..2)
    AuditTrail.delete_all
  end

  it "returns a human readable label for an instance" do
    item = AuditTrail.new
    item.event = 3
    expect(item.event_to_s).to eq("Delete")
    item.event = 4
    expect(item.event_to_s).to eq("User")
  end
  
  it "returns human readbale label for an event code" do
    expect(AuditTrail.event_to_s(-5)).to eq("") # Remember: -1 to -4 work from end of array
    expect(AuditTrail.event_to_s(0)).to eq("")
    expect(AuditTrail.event_to_s(1)).to eq("Create")
    expect(AuditTrail.event_to_s(2)).to eq("Update")
    expect(AuditTrail.event_to_s(3)).to eq("Delete")
    expect(AuditTrail.event_to_s(4)).to eq("User")
    expect(AuditTrail.event_to_s(5)).to eq("")
  end
  
  it "allows a user event to be added" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.user_event(user, "Any old text")
    items = AuditTrail.last(100)
    expect(items.count).to eq(1)
  end

  it "allows a generic create event to be added" do
		user = User.new
		user.email = "UserName1@example.com"
  	AuditTrail.create_event(user, "Any old text")
  	items = AuditTrail.last(100)
  	expect(items.count).to eq(1)
  end

  it "allows a generic update event to be added" do
		user = User.new
		user.email = "UserName2@example.com"
  	AuditTrail.update_event(user, "Any old text")
  	items = AuditTrail.last(100)
  	expect(items.count).to eq(1)
  end

  it "allows a generic delete event to be added" do
		user = User.new
		user.email = "UserName3@example.com"
  	AuditTrail.delete_event(user, "Any old text")
  	items = AuditTrail.last(100)
  	expect(items.count).to eq(1)
	end

  it "allows a create item event to be added" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.create_item_event(user, item, "Any old text")
    items = AuditTrail.last(100)
    expect(items.count).to eq(1)
  end

  it "allows a create item event to be added, new managed item" do
    item = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.create_item_event(user, item, "Any old text")
    items = AuditTrail.last(100)
    expect(items.count).to eq(1)
  end

  it "allows a update item event to be added" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    user = User.new
    user.email = "UserName2@example.com"
    AuditTrail.update_item_event(user, item, "Any old text")
    items = AuditTrail.last(100)
    expect(items.count).to eq(1)
  end

  it "allows a delete item event to be added" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    user = User.new
    user.email = "UserName3@example.com"
    AuditTrail.delete_item_event(user, item, "Any old text")
    items = AuditTrail.last(100)
    expect(items.count).to eq(1)
  end

  it "counts user by year" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.create(date_time: Time.parse("2010-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-01-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    expect(AuditTrail.users_by_year).to eq({"2010"=>1, "2012"=>2, "2019"=>2})
  end

  it "counts user by year, have logged in nil" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.create(date_time: Time.parse("2010-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    AuditTrail.create(date_time: Time.parse("2019-01-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    AuditTrail.create(date_time: Time.parse("2019-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    expect(AuditTrail.users_by_year).to eq({})
  end

  it "counts users by current week" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.create(date_time: Time.parse("2019-11-26"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-11-26"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-11-26"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-11-27"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-11-27"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    expect(AuditTrail.users_by_current_week).to eq({"Friday"=>0, "Monday"=>0, "Saturday"=>0, "Sunday"=>0, "Thursday"=>0, "Tuesday"=>3, "Wednesday"=>2})
  end

  it "counts users by year by week" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.create(date_time: Time.parse("2010-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-01-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    expect(AuditTrail.users_by_year_by_week).to eq({"2010"=>{"43"=>1}, "2012"=>{"39"=>2}, "2019"=>{"04"=>1, "43"=>1}})
  end

  it "counts users by year by month" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.create(date_time: Time.parse("2010-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-01-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    AuditTrail.create(date_time: Time.parse("2019-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged in.")
    expect(AuditTrail.users_by_year_by_month).to eq({"2010"=>{"October"=>1}, "2012"=>{"September"=>2}, "2019"=>{"January"=>1, "October"=>1}})
  end

  it "counts user by year by month, have logged in nil" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.create(date_time: Time.parse("2010-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    AuditTrail.create(date_time: Time.parse("2012-09-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    AuditTrail.create(date_time: Time.parse("2019-01-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    AuditTrail.create(date_time: Time.parse("2019-10-31"), user: user.email, owner: "", identifier: "", version: "", event: 4, description: "User logged out.")
    expect(AuditTrail.users_by_year_by_month).to eq({})
  end

  it "counts user by domain" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.user_event(user, "User logged in.")
    user = User.new
    user.email = "UserName2@sanofi.com"
    AuditTrail.user_event(user, "User logged in.")
    user = User.new
    user.email = "UserName3@s-cubed.com"
    AuditTrail.user_event(user, "User logged in.")
    user = User.new
    user.email = "UserName3@merck.com"
    AuditTrail.user_event(user, "User logged out.")
    expect(AuditTrail.users_by_domain).to eq({"example.com"=>1, "s-cubed.com"=>1, "sanofi.com"=>1, "total"=>3})
  end

  it "counts user by domain, have logged in nil" do
    user = User.new
    user.email = "UserName1@example.com"
    AuditTrail.user_event(user, "User logged out.")
    user = User.new
    user.email = "UserName2@sanofi.com"
    AuditTrail.user_event(user, "User logged out.")
    user = User.new
    user.email = "UserName3@s-cubed.com"
    AuditTrail.user_event(user, "User logged out.")
    user = User.new
    user.email = "UserName3@merck.com"
    AuditTrail.user_event(user, "User logged out.")
    expect(AuditTrail.users_by_domain).to eq({"total"=>0})
  end

	it "allows filtering of events" do
		item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
		user = User.new
		user.email = "UserName1@example.com"
  	20.times do |index|
  		AuditTrail.create_item_event(user, item, "Any old text#{index}")
  		AuditTrail.update_item_event(user, item, "Any old text#{index}")
  		AuditTrail.delete_item_event(user, item, "Any old text#{index}")
  	end
		user.email = "UserName2@example.com"
  	20.times do |index|
  		AuditTrail.create_item_event(user, item, "Any old text#{index}")
  		AuditTrail.update_item_event(user, item, "Any old text#{index}")
  		AuditTrail.delete_item_event(user, item, "Any old text#{index}")
  	end
  	user.email = "UserName3@example.com"
  	20.times do |index|
  		AuditTrail.create_item_event(user, item, "Any old text#{index}")
  		AuditTrail.update_item_event(user, item, "Any old text#{index}")
  		AuditTrail.delete_item_event(user, item, "Any old text#{index}")
  	end
  	user.email = "UserName1@example.com"
    10.times do |index|
      AuditTrail.create_event(user, "Any old text#{index}")
      AuditTrail.update_event(user, "Any old text#{index}")
      AuditTrail.delete_event(user, "Any old text#{index}")
    end
    user.email = "UserName2@example.com"
    10.times do |index|
      AuditTrail.create_event(user, "Any old text#{index}")
      AuditTrail.update_event(user, "Any old text#{index}")
      AuditTrail.delete_event(user, "Any old text#{index}")
    end
    user.email = "UserName3@example.com"
    10.times do |index|
      AuditTrail.create_event(user, "Any old text#{index}")
      AuditTrail.update_event(user, "Any old text#{index}")
      AuditTrail.delete_event(user, "Any old text#{index}")
    end
    user.email = "UserName4@example.com"
    10.times do |index|
      AuditTrail.user_event(user, "Any old text#{index}")
    end
    items = AuditTrail.last(500)
  	expect(items.count).to eq(280)
  	items = AuditTrail.where({:user => "UserName1@example.com"})
    expect(items.count).to eq(90)
  	items = AuditTrail.where({:identifier => item.identifier})
    expect(items.count).to eq(180)
  	items = AuditTrail.where({:owner => item.owner.ra_namespace.short_name})
    expect(items.count).to eq(180)
  	items = AuditTrail.where({:event => 2})
    expect(items.count).to eq(90)
    items = AuditTrail.where({:event => 4})
    expect(items.count).to eq(10)
  	items = AuditTrail.where({:user => "UserName1@example.com", :identifier => item.identifier, :event => 2, :owner => item.owner.ra_namespace.short_name})
    expect(items.count).to eq(20)
    items = AuditTrail.where({:user => "UserName4@example.com"})
    expect(items.count).to eq(10)
	end

  it "allows CSV export of the audit trail" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.scopedIdentifier.semantic_version = "1.2.3"
    user = User.new
    user.email = "UserName1@example.com"
    20.times do |index|
      AuditTrail.create_item_event(user, item, "Any old text#{index}")
      AuditTrail.update_item_event(user, item, "Any old text#{index}")
      AuditTrail.delete_item_event(user, item, "Any old text#{index}")
    end
    user.email = "UserName2@example.com"
    20.times do |index|
      AuditTrail.create_item_event(user, item, "Any old text#{index}")
      AuditTrail.update_item_event(user, item, "Any old text#{index}")
      AuditTrail.delete_item_event(user, item, "Any old text#{index}")
    end
    user.email = "UserName3@example.com"
    20.times do |index|
      AuditTrail.create_item_event(user, item, "Any old text#{index}")
      AuditTrail.update_item_event(user, item, "Any old text#{index}")
      AuditTrail.delete_item_event(user, item, "Any old text#{index}")
    end
    user.email = "UserName1@example.com"
    10.times do |index|
      AuditTrail.create_event(user, "Any old text#{index}")
      AuditTrail.update_event(user, "Any old text#{index}")
      AuditTrail.delete_event(user, "Any old text#{index}")
    end
    user.email = "UserName2@example.com"
    10.times do |index|
      AuditTrail.create_event(user, "Any old text#{index}")
      AuditTrail.update_event(user, "Any old text#{index}")
      AuditTrail.delete_event(user, "Any old text#{index}")
    end
    user.email = "UserName3@example.com"
    10.times do |index|
      AuditTrail.create_event(user, "Any old text#{index}")
      AuditTrail.update_event(user, "Any old text#{index}")
      AuditTrail.delete_event(user, "Any old text#{index}")
    end
    user.email = "UserName4@example.com"
    10.times do |index|
      AuditTrail.user_event(user, "Any old text#{index}")
    end
    items = AuditTrail.order(:id)
  #Xcsv = AuditTrail.to_csv
  #Xwrite_text_file_2(csv, sub_dir, "audit_export.csv")
    keys = ["datetime", "user", "owner", "identifier", "version", "event", "details"]
    results = CSV.read(test_file_path(sub_dir, 'audit_export.csv')).map {|a| Hash[ keys.zip(a) ]}
    items.each_with_index do |item, index|
      #expect(results[index + 1]["datetime"]).to eq(Timestamp.new(item.date_time).to_datetime) # Timestamps will not match
      expect(results[index + 1]["user"]).to eq(item.user)
      expect(results[index + 1]["owner"]).to eq(item.owner)
      expect(results[index + 1]["identifier"]).to eq(item.identifier)
      expect(results[index + 1]["version"]).to eq(item.version)
      expect(results[index + 1]["event"]).to eq(item.event_to_s)
      expect(results[index + 1]["details"]).to eq(item.description)
    end

  end

end
