require 'rails_helper'
require 'rake'

describe "Name Value : Seed" do
  
  before :all do
    Rake.application.rake_require "tasks/name_value_seed"
    Rake::Task.define_task(:environment)
  end

  describe 'name value seed' do
    
    before :each do
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "999")
      NameValue.create(name: "thesaurus_child_identifier", value: "111")      
    end

    let :run_rake_task do
      Rake::Task["name_value:seed"].reenable
      Rake.application.invoke_task "name_value:seed"
    end

    it "clobber the reports table, I" do
      expect(STDIN).to receive(:gets).and_return("y")
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
      run_rake_task
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("4000")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("100000")
    end

    it "clobber the reports table, II" do
      expect(STDIN).to receive(:gets).and_return("Y")
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
      run_rake_task
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("4000")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("100000")
    end

    it "clobber the reports table, no I" do
      expect(STDIN).to receive(:gets).and_return("d")
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
      expect{run_rake_task}.to raise_error(SystemExit, "Operation cancelled.")
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
    end

    it "clobber the reports table, no II" do
      expect(STDIN).to receive(:gets).and_return("n")
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
      expect{run_rake_task}.to raise_error(SystemExit, "Operation cancelled.")
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
    end

    it "clobber the reports table, no III" do
      expect(STDIN).to receive(:gets).and_return("N")
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
      expect{run_rake_task}.to raise_error(SystemExit, "Operation cancelled.")
      expect(NameValue.where(name: "thesaurus_parent_identifier").first.value).to eq("999")
      expect(NameValue.where(name: "thesaurus_child_identifier").first.value).to eq("111")
    end

  end

end