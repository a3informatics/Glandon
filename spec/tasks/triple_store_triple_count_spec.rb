require 'rails_helper'
require 'rake'

describe 'triple store triple_count' do
  
  before :all do
    Rake.application.rake_require "tasks/triple_store_triple_count"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/triple_store/triple_count"
  end

  def run_and_capture_output  
    stdout = StringIO.new
    $stdout = stdout
    Rake.application.invoke_task "triple_store:triple_count"
    $stdout = STDOUT
    Rake::Task["triple_store:triple_count"].reenable
    return stdout.string
  end

  describe 'triple store' do
    
    before :each do
      load_files(schema_files, [])
    end

    it "count" do
      result = run_and_capture_output.split("\n")
      expect(result).to eq(["Triple count: 2033"])
    end

  end

end