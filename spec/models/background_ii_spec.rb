require 'rails_helper'

describe Background do

  def sub_dir
    return "models/background"
  end

  describe "Background Jobs" do

    before :all do
    end

    after :all do
    end

    it "starts a job" do
      description = "A Job 1"
      status = "Begin!"
      job = Background.create
      job.start(description, status) {}
      result = Background.find(job.id)
      expect(result.description).to eq(description)
      expect(result.status).to eq(status)
      expect(result.percentage).to eq(0)
      expect(result.started).to be_within(1.second).of Time.now
    end

    it "update a job" do
      description = "A Job 2"
      status = "Executing"
      percentage = 14
      job = Background.create
      job.start(description, "2") {}
      job.running(status, percentage)
      result = Background.find(job.id)
      expect(result.description).to eq(description)
      expect(result.status).to eq(status)
      expect(result.percentage).to eq(percentage)
    end

    it "end a job" do
      description = "A Job 3"
      status = "Complete"
      percentage = 100
      job = Background.create
      job.start(description, "3") {}
      job.end(status)
      result = Background.find(job.id)
      expect(result.description).to eq(description)
      expect(result.status).to eq(status)
      expect(result.percentage).to eq(percentage)
      expect(result.completed).to be_within(1.second).of Time.now
      expect(result.complete).to be(true)
    end

    it "exception in a job" do
      description = "A Job 3"
      status = "Complete."
      percentage = 100
      e = Exception.new("Exception")
      e.set_backtrace(["A", "b"])
      job = Background.create
      job.start(description, "3") {}
      job.exception(status, e)
      result = Background.find(job.id)
      expect(result.description).to eq(description)
      expect(result.status).to eq("#{status}\nDetails: Exception.\nBacktrace: [\"A\", \"b\"]")
      expect(result.percentage).to eq(percentage)
      expect(result.completed).to be_within(1.second).of Time.now
    end

    it "sets a range and total" do
      job = Background.create
      job.set_range_and_total(30..49, 20)
      expect(job.get_progress).to eq(30)
    end

    it "range and total increment" do
      job = Background.create
      job.set_range_and_total(30..49, 40)
      expect(job.get_progress).to eq(30)
      job.increment
      expect(job.get_progress).to eq(30)
      job.increment
      expect(job.get_progress).to eq(31)
      job.increment
      expect(job.get_progress).to eq(31)
      job.increment
      expect(job.get_progress).to eq(32)
      job.increment
      expect(job.get_progress).to eq(32)
    end

    it "increment with status" do
      status = "Now updated!"
      job = Background.create
      job.set_range_and_total(50..59, 5)
      expect(job.get_progress).to eq(50)
      job.increment_with_status(status)
      expect(job.get_progress).to eq(52)
      result = Background.find(job.id)
      expect(result.status).to eq(status)
    end
    
    it "set a range and total separately" do
      job = Background.create
      job.set_range(50..69)
      job.set_total(20)
      expect(job.get_progress).to eq(50)
      job.increment
      expect(job.get_progress).to eq(51)
      job.set_total(10)
      job.increment
      expect(job.get_progress).to eq(52)
    end

  end

end