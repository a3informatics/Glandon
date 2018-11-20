require 'rails_helper'

describe TabularStandard::Datatype do

  include DataHelpers

  def sub_dir
    return "models/tabular_standard/datatype"
  end

  before :all do
    clear_triple_store
  end

  it "initializes" do
    collection = TabularStandard::Datatype.new
    expect(collection.set).to eq({})
  end

end
  