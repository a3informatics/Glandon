require 'rails_helper'

describe Annotation::ChangeNote do

	include DataHelpers
  include SparqlHelpers
    
	def sub_dir
    return "models/annotation/change_note"
  end

  before :all do
    IsoHelpers.clear_cache
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end
 
  it "validates a valid object" do
    result = Annotation::ChangeNote.new
    result.uri = Uri.new(uri: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1")
    result.timestamp = Time.now
    result.reference = "R"
    result.user_reference = "UR"
    result.description = "D"
    expect(result.valid?).to eq(true)
  end

  it "does not validate an invalid object, text label" do
    result = Annotation::ChangeNote.new
    result.label = "Draft 123 more tesxt €"
    expect(result.valid?).to eq(false)
  end

  it "allows the object to be initialized from hash" do
    result = 
      {
        :uri => "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1", 
        :id => Uri.new(uri: "http://www.assero.co.uk/X/V1#F-ACME_OR_G1_I1").to_id, 
        :label => "Label",
        :timestamp => "2019-01-01",
        :reference => "R",
        :user_reference => "UR",
        :description => "D",
        :rdf_type => "http://www.assero.co.uk/Annotations#ChangeNote",
        :tagged => [],
        :current => [],
        :by_authority => nil
      }
    item = Annotation::ChangeNote.from_h(result)
    result[:timestamp] = "2019-01-01T00:00:00+00:00"
    expect(item.to_h).to eq(result)
  end

  it "allows an object to be exported as SPARQL" do
    sparql = Sparql::Update.new
    allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00 2000"))
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeNote.create(user_reference: "UR", description: "D", reference: "R")
    item.to_sparql(sparql)
  #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_create_sparql_expected.txt")
    check_sparql_no_file(sparql.to_create_sparql, "to_create_sparql_expected.txt")
  end

  it "creates a change note" do
    allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00 2000"))
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeNote.create(user_reference: "UR", description: "D", reference: "R")
    check_file_actual_expected(item.to_h, sub_dir, "create_expected_1.yaml")
  end    

  it "updates a change note" do
    allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00 2000"))
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    item = Annotation::ChangeNote.create(user_reference: "UR", description: "D", reference: "R")
    allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00 2000"))
    item.update(user_reference: "UR1", description: "D1", reference: "R, R1")
    item = Annotation::ChangeNote.find(item.id)
    check_file_actual_expected(item.to_h, sub_dir, "update_expected_1.yaml")
  end    

  it "deletes a change note" do
    allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00 2000"))
    allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
    cn_1 = Annotation::ChangeNote.create(user_reference: "UR1", description: "D2", reference: "R2")
    or_1 = OperationalReferenceV3.create({reference: nil, context: nil}, cn_1)
    cn_1.current << or_1
    cn_1.save
    item = Annotation::ChangeNote.find(cn_1.id)
    item.delete
    expect{Annotation::ChangeNote.find(cn_1.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CN#1234-5678-9012-3456 in Annotation::ChangeNote.")
    expect{Annotation::ChangeNote.find(or_1.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CN#1234-5678-9012-3456_R1 in Annotation::ChangeNote.")
  end    

end