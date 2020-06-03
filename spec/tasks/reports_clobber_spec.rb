require 'rails_helper'
require 'rake'

describe 'reports clobber rake task' do
  
  before :all do
    Rake.application.rake_require "tasks/reports_clobber"
    Rake::Task.define_task(:environment)
  end

  describe 'roles update' do
    
    before do
      AdHocReport.delete_all
      AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
      AdHocReport.create(label: "Report No. 1", sparql_file: "report_1_sparql.txt", results_file: "report_1_results.yaml", last_run: Time.now, active: false, background_id: 0)
    end

    let :run_rake_task do
      Rake::Task["reports:clobber"].reenable
      Rake.application.invoke_task "reports:clobber"
    end

    it "clobber the reports table" do
      expect(AdHocReport.all.count).to eq(3)
      run_rake_task
      expect(AdHocReport.all.count).to eq(0)
    end

  end

end