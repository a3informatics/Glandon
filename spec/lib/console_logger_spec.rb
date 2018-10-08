require 'rails_helper'

describe ConsoleLogger do
  
  before :each do
    #
  end

  after :each do
    #
  end

  it "outputs a debug message" do
    expect(Rails.logger).to receive(:debug).with("[Class                    ][Method                   ] The message.")
    ConsoleLogger.debug("Class", "Method", "The message.")
  end

  it "outputs a info message" do
    expect(Rails.logger).to receive(:info).with("[Class                    ][Method                   ] The message.")
    ConsoleLogger.info("Class", "Method", "The message.")
  end

  it "outputs a error message" do
    expect(Rails.logger).to receive(:error).with("[Class                    ][Method                   ] The message.")
    ConsoleLogger.error("Class", "Method", "The message.")
  end

  it "turns debug on and off" do
    Rails.logger.level = 1
    ConsoleLogger.debug_on
    expect(Rails.logger.level).to eq(0)
    ConsoleLogger.debug_off
    expect(Rails.logger.level).to eq(1)
  end

end