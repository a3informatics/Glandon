require 'rails_helper'

describe Import::ChangeInstructions::Instruction do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers

	def sub_dir
    return "models/import/change_instructions/instruction"
  end

	before :each do
  end

  after :each do
  end

  it "previous" do
    item = Import::ChangeInstructions::Instruction.new 
    item.previous_parent << "C12345"
    expect(item.previous).to hash_equal([["C12345"]])
    item.previous_children << "C333"
    expect(item.previous).to hash_equal([["C12345", "C333"]])
    item.previous_children << "C3334"
    expect(item.previous).to hash_equal([["C12345", "C333"], ["C12345", "C3334"]])
    item.previous_parent << "C12346"
    expect(item.previous).to hash_equal([["C12345", "C333"], ["C12345", "C3334"], ["C12346", "C333"], ["C12346", "C3334"]])
  end

  it "current" do
    item = Import::ChangeInstructions::Instruction.new 
    item.current_parent << "C12345"
    expect(item.current).to hash_equal([["C12345"]])
    item.current_children << "C333"
    expect(item.current).to hash_equal([["C12345", "C333"]])
    item.current_children << "C3334"
    expect(item.current).to hash_equal([["C12345", "C333"], ["C12345", "C3334"]])
    item.current_parent << "C12346"
    expect(item.current).to hash_equal([["C12345", "C333"], ["C12345", "C3334"], ["C12346", "C333"], ["C12346", "C3334"]])
  end

  it "valid, previous children but no current children" do
    item = Import::ChangeInstructions::Instruction.new 
    item.previous_parent << "C12345"
    item.current_parent << "C12346"
    expect(item.valid?).to eq(true)
    item.previous_children << "C3331"
    expect(item.valid?).to eq(false)
    item.current_children << "C4441"
    expect(item.valid?).to eq(true)
  end

  it "valid, no previous children but current children" do
    item = Import::ChangeInstructions::Instruction.new 
    item.previous_parent << "C12345"
    item.current_parent << "C12346"
    expect(item.valid?).to eq(true)
    item.current_children << "C4441"
    expect(item.valid?).to eq(false)
    item.previous_children << "C3331"
    expect(item.valid?).to eq(true)
  end

  it "valid, multiple children mapping I" do
    item = Import::ChangeInstructions::Instruction.new 
    item.previous_parent << "C12345"
    item.current_parent << "C12346"
    item.previous_children << "C3331"
    item.previous_children << "C3332"
    item.current_children << "C4441"
    expect(item.valid?).to eq(true)
    item.current_children << "C4442"
    expect(item.valid?).to eq(false)
  end

  it "valid, multiple children mapping II" do
    item = Import::ChangeInstructions::Instruction.new 
    item.previous_parent << "C12345"
    item.current_parent << "C12346"
    item.previous_children << "C3331"
    item.current_children << "C4441"
    item.current_children << "C4442"
    expect(item.valid?).to eq(true)
    item.previous_children << "C3332"
    expect(item.valid?).to eq(false)
  end

  it "valid, multiple parent mapping I" do
    item = Import::ChangeInstructions::Instruction.new 
    item.previous_parent << "C12345"
    item.previous_parent << "C12346"
    item.current_parent << "C12346"
    expect(item.valid?).to eq(true)
    item.current_parent << "C12347"
    expect(item.valid?).to eq(false)
  end

  it "valid, multiple parent mapping II" do
    item = Import::ChangeInstructions::Instruction.new 
    item.previous_parent << "C12345"
    item.current_parent << "C12346"
    item.current_parent << "C12347"
    expect(item.valid?).to eq(true)
    item.previous_parent << "C12346"
    expect(item.valid?).to eq(false)
  end

  it "valid, multiple current parent" do
    item = Import::ChangeInstructions::Instruction.new 
    item.previous_parent << "C12345"
    item.current_parent << "C12346"
    item.current_parent << "C12347"
    item.previous_children << "C3331"
    item.previous_children << "C3332"
    expect(item.valid?).to eq(false)
  end

end