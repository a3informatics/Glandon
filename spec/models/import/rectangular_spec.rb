require 'rails_helper'

describe Import::Rectangular do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include TurtleHelpers
  include SparqlHelpers

	def sub_dir
    return "models/import/rectangular"
  end

  it "runs no tests, see testing for Import::AdamIg" do
    expect(true).to eq(true)
  end

end