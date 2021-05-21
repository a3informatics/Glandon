require 'rails_helper'

describe "Timepoint" do

  include DataHelpers
  include PublicFileHelpers
  include BiomedicalConceptInstanceFactory

  def sub_dir
    return "models/timepoint"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "create an instance" do
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3301")
      offset = Timepoint::Offset.create(label: "TP", window_minus: 1, window_plus: 3, window_offset: 2, unit: "Week")
      item = Timepoint.create(label: "TP", lower_bound: 1, upper_bound: 3, at_offset: offset.uri)
      actual = Timepoint.find(item.uri)
      expect(actual.label).to eq("TP")
      expect(actual.next_timepoint).to eq(nil)
      expect(actual.at_offset).to eq(offset.uri)
      expect(actual.in_visit).to eq(nil)
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

    it "set unit" do
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3301")
      offset = Timepoint::Offset.create(label: "TP", window_minus: 1, window_plus: 3, window_offset: 2, unit: "Week")
      item = Timepoint.create(label: "TP", lower_bound: 1, upper_bound: 3, at_offset: offset.uri)
      item = Timepoint.find(item.uri)
      item.set_unit("MONTH")
      actual = Timepoint.find(offset.uri)
      expect(actual.unit).to eq("Month")
      item.set_unit("days")
      actual = Timepoint.find(offset.uri)
      expect(actual.unit).to eq("Day")
    end

  end

  describe "method tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
    end

    it "add and remove managed" do
      offset = Timepoint::Offset.create(label: "TPO", window_minus: 1, window_plus: 3, window_offset: 2, unit: "Week")
      tp = Timepoint.create(label: "TP", lower_bound: 1, upper_bound: 3, at_offset: offset.uri)
      bc1 = create_biomedical_concept_instance("WEIGHT1", "WEIGHT")
      bc2 = create_biomedical_concept_instance("BMI1", "BMI")
      bc3 = create_biomedical_concept_instance("AGE1", "RACE")     
      result = tp.add_managed([bc1.uri, bc2.uri, bc3.uri])
      tp = Timepoint.find(tp.uri)
      expect(tp.has_planned_objects.count).to eq(3)
      expect(tp.has_planned.first.is_derived_from).to eq(bc1.uri)
      expect(tp.has_planned[1].is_derived_from).to eq(bc2.uri)
      expect(tp.has_planned[2].is_derived_from).to eq(bc3.uri)
      tp.remove_managed([tp.has_planned[0].uri.to_id, tp.has_planned[1].uri.to_id])
      tp = Timepoint.find(tp.uri)
      expect(tp.has_planned_objects.count).to eq(1)
      expect(tp.has_planned.first.is_derived_from).to eq(bc3.uri)
      tp.remove_managed([tp.has_planned.first.uri.to_id])
      tp = Timepoint.find(tp.uri)
      expect(tp.has_planned_objects.count).to eq(0)
    end

  end

end