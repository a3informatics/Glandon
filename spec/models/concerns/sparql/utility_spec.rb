require 'rails_helper'

describe Sparql::Utility do
	
	include DataHelpers

  before :each do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    @test_class = Sparql::Utility.new
  end

  it "ask" do
    expect(@test_class.ask?("<http://www.assero.co.uk/NS#AAA> isoI:name \"AAA Long\"^^xsd:string", [:isoI])).to eq(true)
    expect(@test_class.ask?("<http://www.assero.co.uk/NS#AAA> isoI:name \"AAAx Long\"^^xsd:string", [:isoI])).to eq(false)
  end

  it "triple count" do
    expect(@test_class.triple_count).to eq(8)
  end

end