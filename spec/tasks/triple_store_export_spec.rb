require 'rails_helper'
require 'rake'

describe 'triple store export' do
  
  before :all do
    Rake.application.rake_require "tasks/triple_store_export"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/triple_store/exort"
  end

  def run_and_capture_output(*params)  
    stdout = StringIO.new
    $stdout = stdout
    Rake::Task["triple_store:export"].invoke(params)
    $stdout = STDOUT
    Rake::Task["triple_store:export"].reenable
    return stdout.string
  end

  describe 'basic tests' do
    
    before :each do
      load_files(schema_files, [])
    end

    it "no params" do
      expect{run_and_capture_output("")}.to raise_error(SystemExit, /A single URI should be supplied/)
    end

    it "multiple params" do
      expect{run_and_capture_output("xxx", "yyy")}.to raise_error(SystemExit, /Only a single parameter (a URI) should be supplied/)
    end

    it "invalid URI" do
      expect{run_and_capture_output("xxx")}.to raise_error(SystemExit, /URI does not look valid: xxx/)
    end

    it "no errors" do
      result = run_and_capture_output("http://www.example.com#exit").split("\n")
      expect(result).to eq(["Triple count: 1696"])
    end

  end

end