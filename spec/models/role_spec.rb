require 'rails_helper'

describe Role do

	include DataHelpers

	it "returns a role as a string" do
    expect(Role.role_to_s(:sys_admin)).to eq("System Admin")
    expect(Role.role_to_s(:not_used)).to eq("")
  end

  it "returns a map of DB identifiers" do
  	expected = { :sys_admin => 1, :content_admin => 2, :curator => 3, :reader => 4 }
  	expect(Role.roles_to_id).to eq(expected)
  end

end
