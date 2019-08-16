require 'rails_helper'

describe Role do

	include DataHelpers

	it "provides a list of roles" do
		expected_key = [:sys_admin, :content_admin, :curator, :reader, :term_reader, :term_curator, :community_reader]
		expected_text = ["System Admin", "Content Admin", "Curator", "Reader", "Terminology Reader", "Terminology Curator", "Community Reader"]
		Role.list.each do |k, v| 
			expect(expected_key.include?(k)).to eq(true) 
			expect(expected_text.include?(v[:display_text])).to eq(true) 
		end
	end

	it "detects if a role is enabled" do
		expect(Role.sys_admin_enabled?).to eq(true)
		expect(Role.sys_admin_disabled?).to eq(false)
	end

	it "detects if a role is disabled" do
		Rails.configuration.roles[:roles][:sys_admin][:enabled] = false
		expect(Role.sys_admin_enabled?).to eq(false)
		expect(Role.sys_admin_disabled?).to eq(true)
	end

	it "returns a role as a string" do
    expect(Role.to_display(:sys_admin)).to eq(Rails.configuration.roles[:roles][:sys_admin][:display_text])
  end

	it "returns a role as a string for an invalid role" do
    expect(Role.to_display(:not_used)).to eq("")
  end

	it "provides a role description" do
    expect(Role.description(:reader)).to eq(Rails.configuration.roles[:roles][:reader][:description])
  end

	it "provides a role description, invalid role" do
    expect(Role.description(:reader_x)).to eq("")
  end

	it "detects if role can be combined with sys admin, no" do
    expect(Role.with_sys_admin(:reader)).to eq(false)
  end

	it "detects if role can be combined with sys admin, yes" do
    expect(Role.with_sys_admin(:content_admin)).to eq(true)
  end

end
