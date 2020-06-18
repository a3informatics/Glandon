require 'rails_helper'

describe ApplicationHelper do

  describe "array" do

    it "find all duplicates" do
  		data = *(1..1000)
  		expect(data.find_all_duplicates).to eq([])
      data[143] = 6
      expect(data.find_all_duplicates).to eq([6])
      data[413] = 6
      expect(data.find_all_duplicates).to eq([6])
      data[613] = 66
      expect(data.find_all_duplicates).to match_array([6, 66])
      data[620] = 66
      expect(data.find_all_duplicates).to match_array([6, 66])
      data[899] = 666
      expect(data.find_all_duplicates).to match_array([6, 66, 666])
	  end

	end

end
