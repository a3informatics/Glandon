require 'rails_helper'

describe String do

  describe "general tests" do

    it "to alpha numeric" do
  		expect("xxx.123.aaa##BBB".to_alphanumeric).to eq("XXX123AAABBB")
      expect("1".to_alphanumeric).to eq("1")
      expect("1aA".to_alphanumeric).to eq("1AA")
      expect("   1aA         ".to_alphanumeric).to eq("1AA")
      expect("123456789the quick brown fox jumps over the lazy dog".to_alphanumeric).to eq("123456789THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG")
      expect("123456789THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG".to_alphanumeric).to eq("123456789THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG")
	  end

	end

end
