require 'rails_helper'
require 'rake'

describe 'name value seed rake task' do
  
  before :all do
    Rake.application.rake_require "tasks/name_value_seed"
    Rake::Task.define_task(:environment)
  end

  describe 'name value seed' do
    
    before do
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "999")
      NameValue.create(name: "thesaurus_child_identifier", value: "111")      
    end

    let :run_rake_task do
      Rake::Task["name_value:seed"].reenable
      Rake.application.invoke_task "name_value:seed"
    end

    it "clobber the reports table" do
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
      run_rake_task
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("3100")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("100000")
    end

  end

end