require 'rails_helper'

describe Sparql::Upload do
	
	include DataHelpers

  before :each do
    clear_triple_store
    @test_class = Sparql::Upload.new
  end

  it "loads a file" do
    base = triple_store.triple_count
    filename = File.join(Rails.root.join("db","load", "test"), "crud_spec.ttl")
    @test_class.send(filename)
    expect(triple_store.triple_count).to eq(base + 9)
  end

  it "loads a file, error" do
    base = triple_store.triple_count
    filename = File.join(Rails.root.join("db","load", "test"), "crud_spec.ttl")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(@test_class).to receive(:send_file).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{@test_class.send(filename)}.to raise_error(Errors::CreateError, "Failed to upload and create an item in the database.")
    expect(triple_store.triple_count).to eq(base)
  end

end