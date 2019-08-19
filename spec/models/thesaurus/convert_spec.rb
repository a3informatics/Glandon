require 'rails_helper'

describe Thesaurus do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers

  def sub_dir
    return "models/thesaurus/convert"
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

  def write_triples(triples, filename, refs=false)
    full_path = test_file_path(sub_dir, filename)
    File.open(full_path, "w+") do |f|
      if refs
        triples.each do |triple| 
          object = triple[:object].is_a?(Uri) ? triple[:object].to_ref : "\"#{triple[:object]}\""
          f << "#{triple[:subject].to_ref} #{triple[:predicate].to_ref} #{object} .\n"
        end
      else
        triples.each {|triple| f << "#{triple[:subject]} #{triple[:predicate]} #{triple[:object]} .\n"}
      end
    end
  end

  describe "triple files" do

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

    it "replaces references" do
      replace_old_reference("<http://www.assero.co.uk/MDRThesaurus/CDISC/V42#CLI-C71620_C41139>")
    end

    it "converts files" do
      files = 
      [
        # "form_crf_test_1.ttl", 
        # "form_example_fields.ttl",
        # "ACME_ANNO 2_1.ttl",
        # "ACME_ANNO 3_1.ttl",      
        # "ACME_ANNO 4_1.ttl",      
        # "ACME_ANNO_1.ttl",      
        # "ACME_BC C17634_2.ttl",      
        # "ACME_BC C25206_1.ttl",      
        # "ACME_BC C25206_4.ttl",      
        # "ACME_BC C25208_1.ttl",      
        # "ACME_BC C25208_2.ttl",      
        # "ACME_BC C25298_1.ttl",      
        # "ACME_BC C25299_1.ttl",      
        # "ACME_BC C25347_1.ttl",      
        # "ACME_BC C49677_1.ttl",      
        # "ACME_BC C81255_1.ttl",      
        # "ACME_VS Domain.ttl",      
        # "ACME_LB Domain.ttl",      
        # "ACME_Topic.ttl",
        # "form_example_general.ttl",
        # "form_example_vs_baseline_new.ttl"
      ]
      files.each do |filename|
  puts "***** Processing #{filename} *****"
        triples = read_triples(filename)
        replace_thesaurus_references(triples)
        write_triples(triples, filename)
      end
    end

  end

  describe "turtle files" do

    def load_definitions
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions((1..59))
    end

    before :all do
    end

    after :all do
      delete_all_public_test_files
    end

    it "converts ttl files" do
      files = 
      [
        "BC.ttl"
      ]
      files.each do |filename|
        clear_triple_store
        full_path = Rails.root.join "db/load/test/#{filename}"
        CRUD.file (full_path)
        query_string = "SELECT ?subject ?predicate ?object WHERE {?subject ?predicate ?object}"
        query_results = Sparql::Query.new.query(query_string, "", [])
        triples = query_results.by_object_set([:subject, :predicate, :object])
        load_definitions
        triples.each do |triple|
          next if triple[:object].is_a?(String)
          triple[:object] = replace_old_reference(triple[:object].to_ref) if triple[:object].to_ref.start_with?("<http://www.assero.co.uk/MDRThesaurus/CDISC/V")
        end
        write_triples(triples, filename, true)
      end
    end

  end

end