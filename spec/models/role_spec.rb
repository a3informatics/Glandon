require 'rails_helper'

describe Role do

	include DataHelpers

	it "returns a role as a string" do
    expect(Role.role_to_s(:sys_admin)).to eq("System Admin")
    expect(Role.role_to_s(:not_used)).to eq("")
  end

end
