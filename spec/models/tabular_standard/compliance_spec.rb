require 'rails_helper'

describe TabularStandard::Compliance do

  include DataHelpers

  def sub_dir
    return "models/tabular_standard/compliance"
  end

  before :all do
    clear_triple_store
  end

  it "initializes" do
    collection = TabularStandard::Compliance.new
    expect(collection.set).to eq({})
  end

end
  