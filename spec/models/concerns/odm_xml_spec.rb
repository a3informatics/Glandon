require 'rails_helper'

describe OdmXml do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/odm_xml"
  end

	before :each do
    clear_triple_store
  end

  it "initialize object, fails to read the odm file" do
    full_path = test_file_path(sub_dir, "odmXXX.xml") #dodgy filename
    error_msg = "Exception raised opening ODM XML file, filename=#{full_path}. No such file or directory @ rb_sysopen - #{full_path}"
		object = OdmXml.new(full_path)
		expect(object.errors.count).to eq(1)
		expect(object.errors.full_messages.to_sentence).to eq(error_msg)		
	end

	it "initialize object, success" do
		full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml.new(full_path)
    expect(object.errors.count).to eq(0)
    expect(object.errors.full_messages.to_sentence).to eq("")    
	end

  it "clean identifier" do
    result = OdmXml.clean_identifier("ABCdef")
    expect(result).to eq("ABCDEF")    
    result = OdmXml.clean_identifier("ABC def")
    expect(result).to eq("ABCDEF")    
    result = OdmXml.clean_identifier("ABC def  % ")
    expect(result).to eq("ABCDEF")    
    result = OdmXml.clean_identifier("ABC def 123 % ")
    expect(result).to eq("ABCDEF123")    
  end

  it "logs exception" do
    e = Exception.new("Exception")
    e.set_backtrace(["A", "b"])
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml.new(full_path)
    e_text = "Message\n#{e}\n#{e.backtrace.join("\n")}"
    expect(ConsoleLogger).to receive(:info).with("KLASS", "Method", "#{e_text}")
    object.exception("KLASS", "Method", e, "Message")
  end

  it "logs error" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = OdmXml.new(full_path)
    expect(ConsoleLogger).to receive(:info).with("KLASS", "Method", "Message")
    object.error("KLASS", "Method", "Message")
  end

end