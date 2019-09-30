require 'rails_helper'

describe "CSVHelpers" do
	
	include DataHelpers
  
  def sub_dir
    return "models/concerns/csv_helpers"
  end

  it "format a class for CSV output" do
    expect(CSVHelpers.format(["Label", "RDF Type"], [["AAA", "BBB"], ["DDDDDDD", "DDDDD"]])).to eq("Label,RDF Type\nAAA,BBB\nDDDDDDD,DDDDD\n")
  end

end