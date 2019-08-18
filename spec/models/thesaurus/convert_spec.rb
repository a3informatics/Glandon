require 'rails_helper'

describe Thesaurus do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers

  def sub_dir
    return "models/thesaurus/convert"
  end

  before :all do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions((1..59))
  end

  after :all do
    delete_all_public_test_files
  end

  def replace_thesaurus_references(triples)
    triples.each do |triple|
      triple[:object] = replace_old_reference(triple[:object]).to_ref if triple[:object].start_with?("<http://www.assero.co.uk/MDRThesaurus/CDISC/V")
    end
  end

  def read_triples(filename)
    results = []
    full_path = Rails.root.join "db/load/test/#{filename}"
    my_array = File.readlines(full_path).map do |line|
      begin
        items = line.match(/\A(?<subject>[\S]+)[\s]+(?<predicate>[\S]+)[\s]+(?<object>"*[\S| ]+"*)[\s]+./)
        results << {subject: items[:subject].strip, predicate: items[:predicate].strip, object: items[:object].strip}
      rescue => e
        byebug
      end
    end 
    return results
  end

  def write_triples(triples, filename)
    full_path = test_file_path(sub_dir, filename)
    File.open(full_path, "w+") do |f|
      triples.each {|triple| f << "#{triple[:subject]} #{triple[:predicate]} #{triple[:object]} .\n"}
    end
  end

  it "replaces references" do
    replace_old_reference("<http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71620_C41139>")
  end

  it "converts files" do
    files = 
    [
      "form_crf_test_1.ttl", 
      "form_example_fields.ttl",
      "ACME_ANNO 2_1.ttl",
      "ACME_ANNO 3_1.ttl",      
      "ACME_ANNO 4_1.ttl",      
      "ACME_ANNO_1.ttl",      
      "ACME_BC C17634_2.ttl",      
      "ACME_BC C25206_1.ttl",      
      "ACME_BC C25206_4.ttl",      
      "ACME_BC C25208_1.ttl",      
      "ACME_BC C25208_2.ttl",      
      "ACME_BC C25298_1.ttl",      
      "ACME_BC C25299_1.ttl",      
      "ACME_BC C25347_1.ttl",      
      "ACME_BC C49677_1.ttl",      
      "ACME_BC C81255_1.ttl",      
      "ACME_VS Domain.ttl",      
      "ACME_LB Domain.ttl",      
      "ACME_Topic.ttl",
      "form_example_general.ttl",
      "form_example_vs_baseline_new.ttl"
    ]
    files.each do |filename|
puts "***** Processing #{filename} *****"
      triples = read_triples(filename)
      replace_thesaurus_references(triples)
      write_triples(triples, filename)
    end
  end

end