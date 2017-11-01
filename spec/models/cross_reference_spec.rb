require 'rails_helper'

describe CrossReference do
	
  include DataHelpers

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
		load_schema_file_into_triple_store("business_operational_extension.ttl")
    load_schema_file_into_triple_store("business_cross_reference.ttl")
  end

  it "will initialize an object"

  it "will creat ean object from a hash"
  
  it "will output as sparql"
  
end