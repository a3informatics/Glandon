require 'rails_helper'

describe Errors do
  
  class TestErrors
    
    include ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_reader :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
    end

  end

  before :each do
    @e = Exception.new("Exception")
    @e.set_backtrace(["A", "b"])
    @e_text = "#{@e.message} #{@e.backtrace.join("\n")}"
    @object = TestErrors.new
    @object.errors.add(:name, 'must be implemented')
    @c_text = "Failed to create Class. Name must be implemented."
    @u_text = "Failed to update Class. Name must be implemented."
    @d_text = "Failed to destroy Class."
    @nf_text = "Failed to find object Class with {:id=>\"14\", :name=>\"fred\"}"
    @a_text = "Buggered"
    @expected_c = "[Class                    ][Method                   ] #{@c_text}"
    @expected_u = "[Class                    ][Method                   ] #{@u_text}"
    @expected_d = "[Class                    ][Method                   ] #{@d_text} #{@e_text}"
    @expected_nf = "[Class                    ][Method                   ] #{@nf_text}"
    @expected_a = "[Class                    ][Method                   ] #{@a_text}"
    @expected_e = "[TestErrors               ][Method                   ] Exception raised: #{@e_text}"
  end

  after :each do
    #
  end

  it "handles a create error" do
    expect(Rails.logger).to receive(:info).with(@expected_c)
    expect{Errors.object_create_error("Class", "Method", @object)}.to raise_error(Errors::CreateError, @c_text)
  end

  it "handles an update error" do
    expect(Rails.logger).to receive(:info).with(@expected_u)
    expect{Errors.object_update_error("Class", "Method", @object)}.to raise_error(Errors::UpdateError, @u_text)
  end

  it "handles an destroy error" do
    expect(Rails.logger).to receive(:info).with(@expected_d)
    expect{Errors.object_destroy_error("Class", "Method", @e)}.to raise_error(Errors::DestroyError, "#{@d_text} #{@e_text}")
  end

  it "handles an not found error" do
    params = {id: "14", name: "fred"}
    expect(Rails.logger).to receive(:info).with(@expected_nf)
    expect{Errors.object_not_found_error("Class", "Method", params)}.to raise_error(Errors::NotFoundError, @nf_text)
  end

  it "handles an applicaton error" do
    message = @a_text
    expect(Rails.logger).to receive(:info).with(@expected_a)
    expect{Errors.application_error("Class", "Method", message)}.to raise_error(Errors::ApplicationLogicError, @a_text)
  end 

end