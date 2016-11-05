require 'rails_helper'

describe FieldValidation do
	
	it "checks a valid identifier" do
    object = IsoConcept.new
		expect(FieldValidation.valid_identifier?(:test, "ABab0123 zxZX ", object)).to eq(true)
	end

  it "checks an invalid identifier - @" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, "ABab@0123 zxZX ", object)).to eq(false)
  end

  it "checks an invalid identifier - \"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, "ABab\"", object)).to eq(false)
  end

  it "checks an invalid identifier - empty" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, "", object)).to eq(false)
  end

  it "checks an invalid identifier - nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_identifier?(:test, nil, object)).to eq(false)
  end

  it "checks a valid prefix" do
    object = IsoConcept.new
    expect(FieldValidation.valid_domain_prefix?(:test, "AZ", object)).to eq(true)
  end

  it "checks an invalid prefix - Az" do
    object = IsoConcept.new
    expect(FieldValidation.valid_domain_prefix?(:test, "Az", object)).to eq(false)
  end

  it "checks an invalid prefix - zA" do
    object = IsoConcept.new
    expect(FieldValidation.valid_domain_prefix?(:test, "zA", object)).to eq(false)
  end

  it "checks an invalid prefix - AAA" do
    object = IsoConcept.new
    expect(FieldValidation.valid_domain_prefix?(:test, "AAA", object)).to eq(false)
  end

  it "checks an invalid prefix - A£" do
    object = IsoConcept.new
    expect(FieldValidation.valid_domain_prefix?(:test, "A£", object)).to eq(false)
  end

  it "checks a valid version - 1" do
    object = IsoConcept.new
    expect(FieldValidation.valid_version?(:test, "1", object)).to eq(true)
  end

  it "checks a valid version - 123456789" do
    object = IsoConcept.new
    expect(FieldValidation.valid_version?(:test, "123456789", object)).to eq(true)
  end

  it "checks an invalid version - \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_version?(:test, "", object)).to eq(false)
  end

  it "checks an invalid version - 1*" do
    object = IsoConcept.new
    expect(FieldValidation.valid_version?(:test, "1*", object)).to eq(false)
  end

  it "checks a valid short name - AShortName" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, "AShortName", object)).to eq(true)
  end

  it "checks a valid short name - AShortName123456789Z" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, "AShortName123456789Z", object)).to eq(true)
  end

  it "checks an invalid short name - A Short Name" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, "A Short Name", object)).to eq(false)
  end

  it "checks an invalid short name - AShortName!" do
    object = IsoConcept.new
    expect(FieldValidation.valid_short_name?(:test, "AShortName!", object)).to eq(false)
  end

  it "checks valid label - A Label A-Za-z0-9.!?,_ \-()" do
    object = IsoConcept.new
    expect(FieldValidation.valid_label?(:test, "A Label", object)).to eq(true)
  end

  it "checks a valid label - A Label.!?,_ -()" do
    object = IsoConcept.new
    expect(FieldValidation.valid_label?(:test, "A Label.!?,_ -()", object)).to eq(true)
  end

  it "checks an invalid label - A Label.!?,_ -()@" do
    object = IsoConcept.new
    expect(FieldValidation.valid_label?(:test, "A Label.!?,_ -()@", object)).to eq(false)
  end

  it "checks an invalid label - A Label.!?,_ -()&" do
    object = IsoConcept.new
    expect(FieldValidation.valid_label?(:test, "A Label.!?,_ -()&", object)).to eq(false)
  end

  it "checks valid date - 1960-02-13" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date?(:test, "1960-02-13", object)).to eq(true)
  end

  it "checks an invalid date - 1960-13-01" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date?(:test, "1960-13-01", object)).to eq(false)
  end

  it "checks an invalid date - 1960-Nov-01" do
    object = IsoConcept.new
    expect(FieldValidation.valid_date?(:test, "1960-Nov-01", object)).to eq(false)
  end

  it "checks valid file - xxx" do
    object = IsoConcept.new
    expect(FieldValidation.valid_files?(:test, "xxx", object)).to eq(true)
  end

  it "checks an invalid file - \"\"" do
    object = IsoConcept.new
    expect(FieldValidation.valid_files?(:test, "", object)).to eq(false)
  end

  it "checks an invalid file - nil" do
    object = IsoConcept.new
    expect(FieldValidation.valid_files?(:test, nil, object)).to eq(false)
  end

end