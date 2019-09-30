require 'rails_helper'
require 'rake'

describe 'roles one rake task' do
  
  before :all do
    Rake.application.rake_require "tasks/roles_one"
    Rake::Task.define_task(:environment)
  end

  describe 'roles one' do
    
    before do
    end

    let :run_rake_task do
      Rake::Task["data:roles_one"].reenable
      Rake.application.invoke_task "data:roles_one"
    end

    it "update the roles table" do
    	Role.destroy_all
      ["sys_admin", "reader", "curator", "content_admin"].each { |x| Role.create name: x }
    	pre_roles = []
    	Role.all.each { |x| pre_roles << x.name }
      run_rake_task
    	post_roles = []
    	Role.all.each { |x| post_roles << x.name }
    	diff = post_roles - pre_roles
      expect(diff.count).to eq(3)
      diff.each { |x| expect(["term_reader", "term_curator", "community_reader"].include?(x)) }
    end

  end

end