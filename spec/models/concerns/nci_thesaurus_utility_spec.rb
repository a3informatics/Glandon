require 'rails_helper'

describe NciThesaurusUtility do
	
  it "checks valid 2 digit C Code" do
    expect(NciThesaurusUtility.c_code?("C12")).to eq(false)
  end

  it "checks valid 3 digit C Code" do
    expect(NciThesaurusUtility.c_code?("C123")).to eq(true)
  end

  it "checks valid 4 digit C Code" do
    expect(NciThesaurusUtility.c_code?("C1234")).to eq(true)
  end

	it "checks valid 5 digit C Code" do
		expect(NciThesaurusUtility.c_code?("C12345")).to eq(true)
	end

  it "checks valid 6 digit C Code" do
    expect(NciThesaurusUtility.c_code?("C123456")).to eq(true)
  end

  it "checks invalid 7 digit C Code" do
    expect(NciThesaurusUtility.c_code?("C1234567")).to eq(false)
  end

  it "checks invalid C Code, no C" do
    expect(NciThesaurusUtility.c_code?("123456")).to eq(false)
  end

  it "checks invalid C Code, l/c c" do
    expect(NciThesaurusUtility.c_code?("c123456")).to eq(false)
  end

  it "checks invalid C Code, non digit" do
    expect(NciThesaurusUtility.c_code?("C123A56")).to eq(false)
  end

  it "extract C Code, valid" do
    expect(NciThesaurusUtility.to_c_code("xxx.xxx.C123xxx.eeee")).to eq("C123")
    expect(NciThesaurusUtility.to_c_code("C1234xxx.eeee")).to eq("C1234")
    expect(NciThesaurusUtility.to_c_code("xxx.xxx.C12356.eeee")).to eq("C12356")
    expect(NciThesaurusUtility.to_c_code("xxx.C123456")).to eq("C123456")
  end

  it "extract C Code, invalid" do
    expect(NciThesaurusUtility.to_c_code("xxx.C1234567")).to eq("C123456")
    expect(NciThesaurusUtility.to_c_code("xxx.xxx.C12.eeee")).to eq("")
  end

end