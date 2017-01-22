require 'rails_helper'

describe FieldValidation do
	
  C_ALL_CHARS = "the dirty brown fox jumps over the lazy dog. " + 
    "THE DIRTY BROWN FOX JUMPS OVER THE LAZY DOG. 0123456789. !?,'\"_-/\\()[]~#*=:;&|<>"

	it "checks a valid identifier" do
    object = IsoConcept.new
		expect(FieldValidation.valid_identifier?(:test, "ABab0123 zxZX ", object)).to eq(true)
    expect(object.errors.count).to eq(0)
	end

  it "checks an invalid identifier, @" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, "ABab@0123 zxZX ", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid identifier, _" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, "AAA_BBB", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid identifier, -" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, "AAA-BBB", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid identifier, \"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, "ABab\"", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid identifier, empty" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, "", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid identifier, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks a valid TC identifier, A" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "A", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid TC identifier, A1" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "A1", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid TC identifier, a" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "a", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid TC identifier, a.a" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "a.a", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid TC identifier, a.1" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "a.1", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid TC identifier, ab.1z.z" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "ab.1z.z", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid TC identifier, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks an invalid TC identifier, \"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, '"', object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains a part with invalid characters")
  end

  it "checks an invalid TC identifier, ab..z" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "ab..z", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an empty part")
  end

  it "checks an invalid TC identifier, ab." do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "ab.", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an empty part")
  end

  it "checks an invalid TC identifier, ab.£.z" do
    object = IsoConcept.new
    expect(FieldValidation.valid_tc_identifier?(:test, "ab.£.z", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains a part with invalid characters")
  end

  it "checks a valid SDTM Domain prefix" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_domain_prefix?(:test, "AZ", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid SDTM Domain prefix, Az" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_domain_prefix?(:test, "Az", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM Domain prefix, zA" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_domain_prefix?(:test, "zA", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM Domain prefix, AAA" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_domain_prefix?(:test, "AAA", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM Domain prefix, A£" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_domain_prefix?(:test, "A£", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM Domain prefix, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_domain_prefix?(:test, "", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM Domain prefix, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_domain_prefix?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks a valid SDTM variable, A1234567" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "A1234567", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid SDTM variable, --234567" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "--234567", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end
  it "checks an invalid SDTM variable, A12345678" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "A12345678", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM variable, 12345678" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "12345678", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM variable, 1CCCCCCC" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "1CCCCCCC", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM variable, VSXXXXXXX" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "VSXXXXXXX", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM variable, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks an invalid SDTM variable, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks a valid SDTM variable, STUDYID" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "STUDYID", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid SDTM variable, VSORRES" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "VSORRES", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid SDTM variable label, This is a label/text" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_label?(:test, "This is a label/text", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid SDTM variable label, This is a label\\text" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_label?(:test, "This is a label\\text", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid SDTM variable label, A" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_name?(:test, "A", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid SDTM variable label, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_label?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks an invalid SDTM variable label, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_label?(:test, "", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks an invalid SDTM variable label, 01234567890123456789012345678901234567890" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_variable_label?(:test, "01234567890123456789012345678901234567890", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, is empty or is too long")
  end

  it "checks a valid version, 1" do
    object = IsoConcept.new
    expect(FieldValidation.valid_version?(:test, 1, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid version, 123456789" do
    object = IsoConcept.new
    expect(FieldValidation.valid_version?(:test, 123456789, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid version, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_version?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks an invalid version, 1*" do
    object = IsoConcept.new
    expect(FieldValidation.valid_version?(:test, "1*", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters, must be an integer")
  end

  it "checks a valid short name, AShortName" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, "AShortName", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid short name, AShortName123456789Z" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, "AShortName123456789Z", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid short name, A Short Name" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, "A Short Name", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid short name, AShortName!" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, "AShortName!", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid short name, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks a valid long name, ALongName" do
    object = IsoConcept.new
    expect(FieldValidation.valid_long_name?(:test, "ALongName", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid long name, ALongName1234567890.!?,_ -()" do
    object = IsoConcept.new
    expect(FieldValidation.valid_long_name?(:test, "ALongName1234567890.!?,_ -()", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid long name, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_long_name?(:test, "", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters or is empty")
  end

  it "checks a valid long name, ALongName|" do
    object = IsoConcept.new
    expect(FieldValidation.valid_long_name?(:test, "ALongName|", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid long name, \"\"'\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_long_name?(:test, "\"'", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid submission value, \" \"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_submission_value?(:test, " ", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid submission value, A VALUE" do
    object = IsoConcept.new
    expect(FieldValidation.valid_submission_value?(:test, "A VALUE", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid submission value, a" do
    object = IsoConcept.new
    expect(FieldValidation.valid_submission_value?(:test, "a", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid submission value, aaaAAA123" do
    object = IsoConcept.new
    expect(FieldValidation.valid_submission_value?(:test, "aaaAAA123 ", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid submission value, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_submission_value?(:test, "", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid submission value, !!" do
    object = IsoConcept.new
    expect(FieldValidation.valid_submission_value?(:test, "!!", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid submission value, \"@ \"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_submission_value?(:test, "@ ", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks a valid SDTM format value, ISO 8601" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_format_value?(:test, "ISO 8601", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid SDTM format value, ISO 3166" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_format_value?(:test, "ISO 3166", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid SDTM format value, ISO 8602" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_format_value?(:test, "ISO 8602", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid value")
  end

  it "checks an invalid SDTM format value, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_format_value?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is not set")
  end

  it "checks a valid SDTM format value, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_sdtm_format_value?(:test, "", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid terminology property value, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_terminology_property?(:test, "", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid terminology property value" do
    object = IsoConcept.new
    expect(FieldValidation.valid_terminology_property?(:test, C_ALL_CHARS, object)).to eq(true)
  end

  it "checks an invalid terminology property value, ±" do
    object = IsoConcept.new
    expect(FieldValidation.valid_terminology_property?(:test, "±", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks a valid label" do
    object = IsoConcept.new
    expect(FieldValidation.valid_label?(:test, "A Label", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid label, Specials" do
    object = IsoConcept.new
    expect(FieldValidation.valid_label?(:test, "A Label.!?,_ -()", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid label, @" do
    object = IsoConcept.new
    expect(FieldValidation.valid_label?(:test, "A Label.!?,_ -()@", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid label, £" do
    object = IsoConcept.new
    expect(FieldValidation.valid_label?(:test, "A Label £", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks a valid question" do
    object = IsoConcept.new
    expect(FieldValidation.valid_question?(:test, "A Question", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid question, Specials" do
    object = IsoConcept.new
    expect(FieldValidation.valid_question?(:test, ".!?,'\"_-/\\()[]~#*=:;&|<>", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid question, Specials and £" do
    object = IsoConcept.new
    expect(FieldValidation.valid_question?(:test, ".!?,'\"_-/\\()[]~#*=:;&|<>£", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid question, #£" do
    object = IsoConcept.new
    expect(FieldValidation.valid_question?(:test, "A Question  #£", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid question, €" do
    object = IsoConcept.new
    expect(FieldValidation.valid_question?(:test, "A Question €", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid question, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_question?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
    expect(object.errors.count).to eq(1)
  end

  it "checks a valid question, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_question?(:test, "\"\"", object)).to eq(true)
    expect(object.errors.full_messages.to_sentence).to eq("")
  end

  it "checks valid date, 1960-02-13" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date?(:test, "1960-02-13", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid date, 1960-13-01" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date?(:test, "1960-13-01", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks an invalid date, 1960-Nov-01" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date?(:test, "1960-Nov-01", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks valid file, xxx" do
    object = IsoConcept.new
    expect(FieldValidation.valid_files?(:test, "xxx", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks an invalid file, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_files?(:test, "", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks an invalid file, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_files?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test is empty")
  end

  it "checks a valid date time" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date_time?(:test, "1960-11-01T12:01:01-05:00", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks a valid date time, no time offset" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date_time?(:test, "1960-11-01TX12:01:01-05:0", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid format date time")
  end

  it "checks an invalid date time" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date_time?(:test, "1960x-11-01T12:01:01-05:00", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid format date time")
  end

  it "checks an invalid date time" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date_time?(:test, "1960-11-01T12:01:£££", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid format date time")
  end

  it "checks a valid markdown" do
    object = IsoConcept.new
    expect(FieldValidation.valid_markdown?(:test, C_ALL_CHARS, object)).to eq(true)
  end

  it "checks valid markdown" do
    object = IsoConcept.new
    expect(FieldValidation.valid_markdown?(:test, "This is some\r\n * markup", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks invalid markdown, contains €" do
    object = IsoConcept.new
    expect(FieldValidation.valid_markdown?(:test, "This is some invalid € markup", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid markdown")
  end

  #it "checks invalid markdown, contains <" do
  #  object = IsoConcept.new
  #  expect(FieldValidation.valid_markdown?(:test, "This is some invalid < markup", object)).to eq(false)
  #  expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid markdown")
  #end

  #it "checks invalid markdown, contains >" do
  #  object = IsoConcept.new
  #  expect(FieldValidation.valid_markdown?(:test, "This is some invalid > markup", object)).to eq(false)
  #  expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid markdown")
  #end

  it "checks valid datatype" do
    object = IsoConcept.new
    expect(FieldValidation.valid_datatype?(:test, "boolean", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks invalid datatype" do
    object = IsoConcept.new
    expect(FieldValidation.valid_datatype?(:test, "surge", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid datatype")
  end

  it "checks valid mapping, simple" do
    object = IsoConcept.new
    expect(FieldValidation.valid_mapping?(:test, "SDTM where X=Y", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid mapping, simple 2" do
    object = IsoConcept.new
    expect(FieldValidation.valid_mapping?(:test, "WT!!!", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end
  
  it "checks valid mapping, all characters" do
    object = IsoConcept.new
    expect(FieldValidation.valid_mapping?(:test, C_ALL_CHARS, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end
  
  it "checks valid mapping, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_mapping?(:test, "\"\"", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end
  
  it "checks valid mapping" do
    object = IsoConcept.new
    expect(FieldValidation.valid_mapping?(:test, "[NOT SUBMITTED]", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end
  
  it "checks invalid mapping" do
    object = IsoConcept.new
    expect(FieldValidation.valid_mapping?(:test, "[NOT SUBMITTED]@", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end
  
  it "checks invalid mapping, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_mapping?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end
  
  it "checks valid format, empty \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, "2", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid format, d" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, "2", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid format, dd" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, "22", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid format, ddddd" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, "22111", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid format, dd.d" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, "22.1", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid format, d.ddddddd" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, "0.111111", object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks invalid format, ad" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, "a2", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks invalid format, d-d" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, "2-2", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks invalid format, .d" do
    object = IsoConcept.new
    expect(FieldValidation.valid_format?(:test, ".2", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains invalid characters")
  end

  it "checks valid boolean, true" do
    object = IsoConcept.new
    expect(FieldValidation.valid_boolean?(:test, true, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid boolean, false" do
    object = IsoConcept.new
    expect(FieldValidation.valid_boolean?(:test, false, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks invalid boolean, nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_boolean?(:test, nil, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid boolean value")
  end

  it "checks invalid boolean, \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_boolean?(:test, "", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid boolean value")
  end

  it "checks invalid boolean, \"x\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_boolean?(:test, "x", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid boolean value")
  end

  it "checks valid integer, 1" do
    object = IsoConcept.new
    expect(FieldValidation.valid_integer?(:test, 1, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid integer, -1" do
    object = IsoConcept.new
    expect(FieldValidation.valid_integer?(:test, -1, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid integer, 0" do
    object = IsoConcept.new
    expect(FieldValidation.valid_integer?(:test, 0, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks valid integer, 12340" do
    object = IsoConcept.new
    expect(FieldValidation.valid_integer?(:test, 12340, object)).to eq(true)
    expect(object.errors.count).to eq(0)
  end

  it "checks invalid integer, \"c\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_integer?(:test, "c", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid integer value")
  end

  it "checks invalid integer, \"12c\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_integer?(:test, "12c", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid integer value")
  end

  it "checks valid positive integer, 1" do
    object = IsoConcept.new
    expect(FieldValidation.valid_positive_integer?(:test, 1, object)).to eq(true)
  end

  it "checks invalid positive integer, -1" do
    object = IsoConcept.new
    expect(FieldValidation.valid_positive_integer?(:test, -1, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid positive integer value")
  end

  it "checks invalid positive integer, 0" do
    object = IsoConcept.new
    expect(FieldValidation.valid_positive_integer?(:test, 0, object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid positive integer value")
  end

  it "checks valid positive integer, 12" do
    object = IsoConcept.new
    expect(FieldValidation.valid_positive_integer?(:test, 12, object)).to eq(true)
  end

  it "checks invalid integer, \"12c\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_positive_integer?(:test, "12c", object)).to eq(false)
    expect(object.errors.full_messages.to_sentence).to eq("Test contains an invalid positive integer value")
  end

end