require 'rails_helper'
require 'rake'

describe 'triple store export' do

  include SdtmSponsorDomainFactory
  
  before :all do
    Rake.application.rake_require "tasks/triple_store_export"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/triple_store/exort"
  end

  def run_and_capture_output  
    stdout = StringIO.new
    $stdout = stdout
    Rake::Task["triple_store:export"].invoke
    $stdout = STDOUT
    Rake::Task["triple_store:export"].reenable
    return stdout.string
  end

  before :each do
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_identification.ttl")
  end

  after :each do
    Rake::Task["triple_store:export"].reenable
  end

  it "no params" do
    ARGV.replace ['command']
    expect{run_and_capture_output}.to raise_error(SystemExit, /A single URI should be supplied/)
  end

  it "invalid URI" do
    ARGV.replace ['command', 'wwww']
    expect{run_and_capture_output}.to raise_error(SystemExit, "URI does not look valid: wwww")
  end

  it "no errors" do
    item = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
    ARGV.replace ['command', "#{item.uri}"]
    result = run_and_capture_output.split("\n")
    expect(result[0]).to start_with("Exported http://www.s-cubed.dk/AAA/V1#SPD to /Users/daveih/Documents/rails/Glandon/public/test/SPARQL")
  end

  it "multiple params" do
    ARGV.replace ['command', 'xxx', 'yyy']
    expect{run_and_capture_output}.to raise_error(SystemExit, "Only a single parameter (a URI) should be supplied")
  end
  
end