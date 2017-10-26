require 'rails_helper'

describe Role do

	include DataHelpers

	it "provides a list of roles" do
		expected_key = [:sys_admin, :content_admin, :curator, :reader, :term_reader, :term_curator]
		expected_text = ["System Admin", "Content Admin", "Curator", "Reader", "Terminology Reader", "Terminology Curator"]
		Role.list.each do |k, v| 
		#puts "#{k}, #{v}"
			expect(expected_key.include?(k)).to eq(true) 
			expect(expected_text.include?(v[:display_text])).to eq(true) 
		end
	end

	it "detects if a role is enabled" do
		expect(ENV).to receive(:[]).with(:sys_admin.to_s).and_return("true")
		expect(Role.sys_admin_enabled?).to eq(true)
	end

	it "detects if a role is disabled" do
		expect(ENV).to receive(:[]).with(:sys_admin.to_s).and_return("false")
		expect(Role.sys_admin_enabled?).to eq(false)
	end

	it "returns a role as a string" do
    expect(Role.to_display(:sys_admin)).to eq("System Admin")
  end

	it "returns a role as a string for an invalid role" do
    expect(Role.to_display(:not_used)).to eq("")
  end

end
