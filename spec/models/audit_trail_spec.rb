require 'rails_helper'

describe AuditTrail do

	include DataHelpers

	before :all do
    clear_triple_store
    AuditTrail.delete_all
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("IsoNamespace.ttl")
    load_test_file_into_triple_store("iso_managed_data.ttl")
    load_test_file_into_triple_store("iso_managed_data_2.ttl")
    load_test_file_into_triple_store("iso_managed_data_3.ttl")
    clear_iso_concept_object
  end

  it "returns a human readable label for an instance" do
    item = AuditTrail.new
    item.event = 3
    expect(item.event_to_s).to eq("Delete")
  end
  
  it "returns human readbale label for an event code" do
    expect(AuditTrail.event_to_s(-5)).to eq("") # Remember: -1 to -4 work from end of array
    expect(AuditTrail.event_to_s(0)).to eq("")
    expect(AuditTrail.event_to_s(1)).to eq("Create")
    expect(AuditTrail.event_to_s(2)).to eq("Update")
    expect(AuditTrail.event_to_s(3)).to eq("Delete")
    expect(AuditTrail.event_to_s(4)).to eq("")
  end
  
  it "allows a create event to be added" do
		item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
		user = User.new
		user.email = "UserName1@example.com"
  	AuditTrail.create_event(user, item, "Any old text")
  	items = AuditTrail.last(100)
  	expect(items.count).to eq(1)
  end

  it "allows a update event to be added" do
		item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
		user = User.new
		user.email = "UserName2@example.com"
  	AuditTrail.update_event(user, item, "Any old text")
  	items = AuditTrail.last(100)
  	expect(items.count).to eq(1)
  end

  it "allows a delete event to be added" do
		item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
		user = User.new
		user.email = "UserName3@example.com"
  	AuditTrail.delete_event(user, item, "Any old text")
  	items = AuditTrail.last(100)
  	expect(items.count).to eq(1)
	end

	it "allows filtering of events" do
		item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
		user = User.new
		user.email = "UserName1@example.com"
  	20.times do |index|
  		AuditTrail.create_event(user, item, "Any old text#{index}")
  		AuditTrail.update_event(user, item, "Any old text#{index}")
  		AuditTrail.delete_event(user, item, "Any old text#{index}")
  	end
		user.email = "UserName2@example.com"
  	20.times do |index|
  		AuditTrail.create_event(user, item, "Any old text#{index}")
  		AuditTrail.update_event(user, item, "Any old text#{index}")
  		AuditTrail.delete_event(user, item, "Any old text#{index}")
  	end
  	user.email = "UserName3@example.com"
  	20.times do |index|
  		AuditTrail.create_event(user, item, "Any old text#{index}")
  		AuditTrail.update_event(user, item, "Any old text#{index}")
  		AuditTrail.delete_event(user, item, "Any old text#{index}")
  	end
  	items = AuditTrail.last(200)
  	expect(items.count).to eq(180)
  	items = AuditTrail.where({:user => "UserName1@example.com"})
    expect(items.count).to eq(60)
  	items = AuditTrail.where({:identifier => item.identifier})
    expect(items.count).to eq(180)
  	items = AuditTrail.where({:owner => item.owner})
    expect(items.count).to eq(180)
  	items = AuditTrail.where({:event => 2})
    expect(items.count).to eq(60)
  	items = AuditTrail.where({:user => "UserName1@example.com", :identifier => item.identifier, :event => 2, :owner => item.owner})
    expect(items.count).to eq(20)
	end

end
