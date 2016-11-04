require 'rails_helper'

describe BaseDatatype do
	
	it "obtain xsd datatype" do
		expect(BaseDatatype.to_xsd(BaseDatatype::C_INTEGER)).to eq("integer")
	end

  it "handles missing xsd datatype" do
    expect(BaseDatatype.to_xsd("x")).to eq("")
  end

  it "obtain label for datatype" do
    expect(BaseDatatype.to_label(BaseDatatype::C_STRING)).to eq("String")
  end

  it "handles missing label for datatype" do
    expect(BaseDatatype.to_label("r")).to eq("")
  end

  it "obtain generic datatype" do
    expect(BaseDatatype.from_xsd("http://www.w3.org/2001/XMLSchema#integer")).to eq("integer")
  end

  it "handles missing xsd datatype" do
    expect(BaseDatatype.from_xsd("http://www.w3.org/2001/XMLSchema#worm")).to eq("")
  end

end