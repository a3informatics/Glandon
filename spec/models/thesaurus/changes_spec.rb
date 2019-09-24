require 'rails_helper'

describe "Thesaurus::Changes" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers

  def sub_dir
    return "models/thesaurus/changes"
  end

  before :all do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_versions((1..59))
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

  def check_changes(actual, expected, base_version)
    result = true
    expected.each do |cl, expect|
      actual[:items][cl][:status].each_with_index do |s, index|
        correct = @status_map[expect[index]] == s[:status]
        puts colourize("Mismatch for #{cl}, version: #{base_version+index} found ':#{s[:status]}', expected ':#{@status_map[expect[index]]}'", "red") if !correct
        result = result && correct
      end
    end
    expect(result).to be(true)
  end

  it "code list changes" do
    expected = 
    {
      #        Created = :C, Update= :U, Deleted = :D, No change = :-, Not present = :~
      #        [ 2007             | 2008                          | 2009              | 2010              | 2011              | 2012          | 2013          | 2014              | 2015          | 2016          | 2017          | 2018          | 2019  ]
      #        [ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59]
      C66787:  [:~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :D],
      C67152:  [:~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :U, :U, :-, :-, :U, :-, :-, :U, :-, :U, :U, :U, :-, :-, :U, :U, :-, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :-, :U, :U, :U, :U, :U, :U, :U, :U, :U], # TSPARM 
      C71620:  [:~, :~, :~, :~, :~, :C, :-, :-, :U, :-, :U, :-, :-, :U, :U, :U, :U, :U, :U, :U, :-, :-, :-, :-, :-, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :-, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U, :U], # UNIT
      C78417:  [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :U, :-, :U, :-, :U, :-, :-, :-, :-, :-, :-, :U, :-, :U, :U, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-], #
      C100142: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :U, :D, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :U, :-, :-, :-, :-],
      C100143: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :U, :-, :-, :-, :U, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-], # NPI1TN <<< Check
      C100150: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :D, :~, :~, :~, :~, :~, :~, :~, :~], # CGI01TC <<< Check
      C100151: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-], # MNSI1TN
      C100161: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C100169: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C101808: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :-, :U, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C101832: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :D, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~],
      C101848: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :U, :-, :-, :-, :-],
      C101849: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C101860: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C101867: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C102583: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C103460: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :U, :-, :-, :U, :U, :-, :-, :-, :-, :U, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C103472: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C105137: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C106480: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :U, :-, :-, :-, :-, :U, :U, :U, :-, :-, :-, :-, :-, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C106658: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :U, :U, :-, :U, :-, :-, :U, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C115406: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C117991: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C120522: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :-, :-, :-, :-, :U, :-, :U, :-, :-, :-, :-, :-, :U], # HESTRESC
      C120986: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :U, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C122006: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-, :-],
      C141655: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-],
      C141660: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :U, :-, :-, :-, :-, :-],
      C141669: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-],
      C141671: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :-, :-, :-, :-, :-],
      C142187: [:~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :~, :C, :-, :U, :-, :-, :-, :-]
    }
    ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
    actual = ct.changes(59)
    check_changes(actual, expected, 1)
  end

end