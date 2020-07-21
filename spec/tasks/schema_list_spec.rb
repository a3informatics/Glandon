require 'rails_helper'
require 'rake'

describe 'schema list' do
  
  before :all do
    Rake.application.rake_require "tasks/schema_list"
    Rake::Task.define_task(:environment)
  end

  def sub_dir
    return "tasks/schema_list"
  end

  def run_and_capture_output  
    stdout = StringIO.new
    $stdout = stdout
    #Rake::Task["schema:list"].reenable
    Rake.application.invoke_task "schema:list"
    $stdout = STDOUT
    Rake::Task["schema:list"].reenable
    return stdout.string
  end

  describe 'schema' do
    
    before :each do
      load_files(schema_files, [])
    end

    it "list" do
      results = run_and_capture_output.split("\n")
      check_file_actual_expected(results, sub_dir, "output_expected.yaml", equate_method: :hash_equal)
    end

  end

end