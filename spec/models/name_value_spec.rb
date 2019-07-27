require 'rails_helper'

RSpec.describe NameValue, type: :model do

  include DataHelpers
	include PauseHelpers

  before :each do
    NameValue.destroy_all
  end

  after :each do
    NameValue.destroy_all
  end

  it "next" do
    NameValue.create(name: "x", value: "15")
    expect(NameValue.next("x")).to eq(15)
    expect(NameValue.next("x")).to eq(16)
  end

end
