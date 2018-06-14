require 'rails_helper'

describe BaseDatatype do
	
	include DataHelpers

  def sub_dir
    return "models/concerns"
  end

  it "obtain xsd datatype - integer" do
		expect(BaseDatatype.to_xsd(BaseDatatype::C_INTEGER)).to eq("integer")
	end

  it "obtain xsd datatype - dateTime" do
    expect(BaseDatatype.to_xsd(BaseDatatype::C_DATETIME)).to eq("dateTime")
  end

  it "obtain xsd datatype - error" do
    expect(BaseDatatype.to_xsd("x")).to eq("")
  end

  it "obtain label for datatype - string" do
    expect(BaseDatatype.to_label(BaseDatatype::C_STRING)).to eq("String")
  end

  it "obtain label for datatype - error" do
    expect(BaseDatatype.to_label("r")).to eq("")
  end

  it "obtain generic from xsd datatype - float" do
    expect(BaseDatatype.from_xsd("http://www.w3.org/2001/XMLSchema#float")).to eq(BaseDatatype::C_FLOAT)
  end

  it "obtain generic from xsd datatype - string" do
    expect(BaseDatatype.from_xsd("http://www.w3.org/2001/XMLSchema#string")).to eq(BaseDatatype::C_STRING)
  end

  it "obtain generic from xsd datatype - positive integer" do
    expect(BaseDatatype.from_xsd("http://www.w3.org/2001/XMLSchema#positiveInteger")).to eq(BaseDatatype::C_POSITIVE_INTEGER)
  end

  it "handles generic from xsd datatype - error" do
    expect(BaseDatatype.from_xsd("http://www.w3.org/2001/XMLSchema#worm")).to eq(BaseDatatype::C_STRING)
  end

  it "obtain generic from xsd datatype fragment - float" do
    expect(BaseDatatype.from_xsd_fragment("float")).to eq(BaseDatatype::C_FLOAT)
  end

  it "obtain generic from xsd datatype fragment - string" do
    expect(BaseDatatype.from_xsd_fragment("string")).to eq(BaseDatatype::C_STRING)
  end

  it "obtain generic from xsd datatype fragment - positive integer" do
    expect(BaseDatatype.from_xsd_fragment("positiveInteger")).to eq(BaseDatatype::C_POSITIVE_INTEGER)
  end

  it "handles generic from xsd datatype fragment - error" do
    expect(BaseDatatype.from_xsd_fragment("worm")).to eq(BaseDatatype::C_STRING)
  end

  it "obtain generic from short label - float" do
    expect(BaseDatatype.from_short_label("F")).to eq("float")
  end
  
  it "obtain generic from short label - error" do
    expect(BaseDatatype.from_short_label("X")).to eq("string")
  end
  
  it "obtain generic to short label datatype - Integer" do
    expect(BaseDatatype.to_short_label("integer")).to eq("I")
  end

  it "obtain generic to short label datatype - String" do
    expect(BaseDatatype.to_short_label("string")).to eq("S")
  end

  it "obtain generic to short label datatype - error" do
    expect(BaseDatatype.to_short_label("stringx")).to eq("")
  end

  it "obtain generic to ODM datatype - String" do
    expect(BaseDatatype.to_odm("string")).to eq("text")
  end

  it "obtain generic to ODM datatype - Date" do
    expect(BaseDatatype.to_odm("date")).to eq("date")
  end

  it "obtain generic to ODM datatype - dateTime" do
    expect(BaseDatatype.to_odm("dateTime")).to eq("datetime")
  end

  it "obtain generic to ODM datatype - error" do
    expect(BaseDatatype.to_odm("datex")).to eq("")
  end

  it "provides a set of displayable types" do
    result = 
      {
        "boolean" => {:xsd_fragment=>"boolean", :xsd=>"http://www.w3.org/2001/XMLSchema#boolean", :label=>"Boolean", :short_label=>"B", :odm=>"boolean", :display=>true},
        "date" => {:xsd_fragment=>"date", :xsd=>"http://www.w3.org/2001/XMLSchema#date", :label=>"Date", :short_label=>"D", :odm=>"date", :display=>true},
        "dateTime" => {:xsd_fragment=>"dateTime", :xsd=>"http://www.w3.org/2001/XMLSchema#dateTime", :label=>"Datetime", :short_label=>"D+T", :odm=>"datetime", :display=>true},
        "float" => {:xsd_fragment=>"float", :xsd=>"http://www.w3.org/2001/XMLSchema#float", :label=>"Float", :short_label=>"F", :odm=>"float", :display=>true},
        "integer" => {:xsd_fragment=>"integer", :xsd=>"http://www.w3.org/2001/XMLSchema#integer", :label=>"Integer", :short_label=>"I", :odm=>"integer", :display=>true},
        "string" => {:xsd_fragment=>"string", :xsd=>"http://www.w3.org/2001/XMLSchema#string", :label=>"String", :short_label=>"S", :odm=>"text", :display=>true},
        "time" => {:xsd_fragment=>"time", :xsd=>"http://www.w3.org/2001/XMLSchema#time", :label=>"Time", :short_label=>"T", :odm=>"time", :display=>true}
      }
    expect(BaseDatatype.display).to eq(result)
  end

  it "allows for the generic datatype to be checked as valid" do
    expect(BaseDatatype.valid?("string")).to eq(true)
  end

  it "allows for the generic datatype to be checked as invalid" do
    expect(BaseDatatype.valid?("stringx")).to eq(false)
  end

  it "allows the whole map to be exported as JSON" do
  #write_text_file_2(BaseDatatype.to_json, sub_dir, "base_datatype_json.txt")
    result = read_text_file_2(sub_dir, "base_datatype_json.txt")
    expect(BaseDatatype.to_json).to eq(result)
  end

end