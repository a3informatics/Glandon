# frozen_string_literal: true


# require 'rspec'
# require 'allure-rspec'
require "allure-rspec"

FILEPATH="/Users/Kirsten/Documents/Testing/Run01/"

RSpec.configure do |config|
  config.formatter = AllureRspecFormatter
end

AllureRspec.configure do |config|
      config.results_directory = FILEPATH
      config.logging_level = Logger::INFO
      # these are used for creating links to bugs or test cases where {} is replaced with keys of relevant items
      config.link_tms_pattern = "http://www.jira.com/browse/{}"
      config.link_issue_pattern = "http://www.jira.com/browse/{}"
    end


describe 'MySpec', :feature => "Some feature", :severity => :normal do


  it "should be critical", :story => "First story", :severity => :critical, :testId => 99 do
    "string".should == "string"
  end

  it "should be steps enabled", :story => ["First story", "Second story"], :testId => 31 do |e|

    e.step "step1" do |s|
      s.attach_file "screenshot1", take_screenshot_as_file
    end

    e.step "step2" do
      5.should be > 0
    end

    e.step "step3" do
      0.should == 0
    end

    e.attach_file "screenshot2", take_screenshot_as_file
  end
end


describe 'Some usecase 1', severity: :normal do
  it 'should have some steps' do |t|
    t.run_step 'step1' do
      t.add_attachment(
        name: 'attachment',
        source: 'Some string',
        type: Allure::ContentType::TXT,
        test_case: false
      )
      expect(1).to eq(1)
    end

    Allure.run_step 'step2' do
      expect(0).to eq(1)
    end
  end

  it "string 'aaa' cannot be equal to string 'bbb'", severity: :critical do
    expect('aaa').to eq('bbb')
  end

  it 'must be broken test case' do
    raise 'Unexpected exception'
  end
end
