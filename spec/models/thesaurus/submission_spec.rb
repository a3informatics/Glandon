require 'rails_helper'

describe Thesaurus do

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

  def check_submission(actual, expected, base_version)
    result = true
    expected.each do |expect|
      if actual[:items][expect[:key]].key?
        item = actual[:items][expect[:key]]
        item[:status].each_with_index do |status, index|
          date = actual[:versions][index]
          next if date != expect[:date]
          correct = expect[:notation] == status[:notation] && expect[:previous] == status[:previous]
          puts colourize("Mismatch for #{expect[:key]}, date: #{expect[:date]} found '#{status[:notation]} -> #{status[:notation]}', expected '#{expect[:notation]} -> #{expect[:notation]}'", "red") if !correct
          result = result && correct
        end
      end
    end
    expect(result).to be(true)
  end

  it "submission changes" do
    expected =
    [
      { date: "2014-06-27", key: "C101859.C17998",    previous: "Unknown",                              notation: "UNKNOWN" },
      { date: "2014-12-16", key: "C101841.C100040",   previous: "GRADE 0",                              notation: "TIMI GRADE 0"},
      { date: "2014-12-16", key: "C66737.C15600",     previous: "Phase I Trial",                        notation: "PHASE I TRIAL"},
      { date: "2014-12-16", key: "C71620.C48500",     previous: "IN",                                   notation: "in"},
      { date: "2014-12-16", key: "C101840.C77271",    previous: "Killip CLASS III",                     notation: "KILLIP CLASS III"},
      { date: "2015-12-18", key: "C71620.C66965",     previous: "per sec",                              notation: "/sec"},
      { date: "2015-12-18", key: "C71620.C66967",     previous: "per min",                              notation: "/min"},
      { date: "2015-12-18", key: "C100129.C102121",   previous: "SF36 v2.0 ACUTE",                      notation: "SF36 V2.0 ACUTE"},
      { date: "2015-12-18", key: "C100129.C100775",   previous: "SF36 v1.0 STANDARD",                   notation: "SF36 V1.0 STANDARD"},
      { date: "2016-12-13", key: "C128689.C43823",    previous: "BHUTANESE",                            notation: "BARBADIAN"},
      { date: "2016-12-13", key: "C67154.C106514",    previous: "Cytokeratin Fragment 21-1",            notation: "Cytokeratin 19 Fragment 21-1"},
      { date: "2016-12-13", key: "C101847.C116146",   previous: "LATELOSS",                             notation: "LLMLOSS"},
      { date: "2016-12-13", key: "C71620.C122230",    previous: "ugeq/L",                               notation: "ugEq/L"},
      { date: "2017-03-31", key: "C65047.C116210",    previous: "PRA",                                  notation: "PRAB"},
      { date: "2017-03-31", key: "C106650.C106926",   previous: "ADL03-Select items Without Help",      notation: "ADL03-Select Items Without Help"},
      { date: "2017-03-31", key: "C100153.C101013",   previous: "FPSR1-How Much do you Hurt",           notation: "FPSR1-How Much Do You Hurt"},
      { date: "2017-03-31", key: "C112450.C112688",   previous: "SGRQ02-If You Have Ever Held a job",   notation: "SGRQ02-If You Have Ever Held a Job"},
      { date: "2017-06-30", key: "C85491.C112031",    previous: "FILOVIRUS",                            notation: "FILOVIRIDAE"},
      { date: "2017-06-30", key: "C100129.C100763",   previous: "CGI",                                  notation: "CGI GUY"},
      { date: "2017-06-30", key: "C124298.C125992",   previous: "BRUGGERMAN MRD 2010",                  notation: "BRUGGEMANN MRD 2010"},
      { date: "2017-06-30", key: "C124298.C126013",   previous: "HARTMANN PANCREATIC CANCER 2012",      notation: "HARTMAN PANCREATIC CANCER 2012"},
      { date: "2017-09-29", key: "C74456.C12774",     previous: "ARTERY, PULMONARY",                    notation: "PULMONARY ARTERY BRANCH"},
      { date: "2017-09-29", key: "C120528.C128982",   previous: "Mycobacterium Tuberculosis",           notation: "Mycobacterium tuberculosis"},
      { date: "2017-12-22", key: "C120528.C128983",   previous: "Mycobacterium Tuberculosis Complex",   notation: "Mycobacterium tuberculosis Complex"}
    ]    
    ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V37#TH"))
    actual = ct.submission(2)
  byebug
    check_submisision(actual, expected)
  end

end