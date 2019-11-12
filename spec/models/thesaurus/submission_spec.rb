require 'rails_helper'

describe "Thesaurus Submission" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers

  def sub_dir
    return "models/thesaurus/submission"
  end

  before :all do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_versions((1..61))
    @status_map = {:~ => :not_present, :- => :no_change, :C => :created, :U => :updated, :D => :deleted}
  end

  after :all do
    delete_all_public_test_files
  end

  def load_version(version)
    load_data_file_into_triple_store("cdisc/ct/CT_V#{version}.ttl")
  end

  def load_versions(range)
    range.each {|n| load_version(n)}
  end

  def check_submission(actual, expected)
    result = true
    correct = actual[:items].count == expected[:count] || expected[:count] == -1 
    result = result && correct
    puts colourize("Mismatch of count, date: #{expected[:date]}, expected '#{expected[:items].count}' item(s) but got '#{actual[:items].count}'", "red") if !correct
    expected[:items].each do |expect|
      if actual[:items].key?(expect[:key])
        item = actual[:items][expect[:key]]
        index = actual[:versions].index(expected[:date])
        if !index.nil?
          status = item[:status][index]
          correct = expect[:notation] == status[:notation] && expect[:previous] == status[:previous]
          puts colourize("Mismatch for #{expect[:key]}, date: #{expected[:date]} found '#{status[:previous]}' -> '#{status[:notation]}', expected '#{expect[:previous]}' -> '#{expect[:notation]}'", "red") if !correct
          puts colourize("Match for #{expect[:key]}, date: #{expected[:date]} found '#{status[:previous]}' -> '#{status[:notation]}', expected '#{expect[:previous]}' -> '#{expect[:notation]}'", "green") if correct
          result = result && correct
        else
          puts colourize("Date not found for #{expect[:key]}, date: #{expected[:date]} nothing found, expected '#{expect[:previous]}' -> '#{expect[:notation]}'", "red")
          result = result && false
        end
      else
        puts colourize("No result found for expected #{expect[:key]}, date: #{expected[:date]}. Expected '#{expect[:previous]}' -> '#{expect[:notation]}'", "red")
        result = result && false
      end
    end
    result
  end

  it "submission changes" do
    expected = read_yaml_file(sub_dir, "submission_expected.yaml")
    result = true
    first = 1
    last = 61
    (first..last).each do |version|
      puts "***** V#{version}, #{expected.find{|x| x[:version] == version}[:date]} *****"
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V#{version}#TH"))
      actual = ct.submission(1)
      next_result = check_submission(actual, expected.find{|x| x[:version] == version})
      check_file_actual_expected(actual, sub_dir, "submission_expected_#{version}.yaml", equate_method: :hash_equal)
      result = result && next_result
    end
    expect(result).to be(true)
  end

end