require 'rails_helper'

describe "Thesaurus::Difference" do

  include DataHelpers

  def sub_dir
    return "models/thesaurus/difference"
  end

  def old_sub_dir
    return "models/thesaurus"
  end

  def compare(old_filename, new_filename)
    old_result = read_yaml_file(old_sub_dir, old_filename)
    new_result = read_yaml_file(sub_dir, new_filename)
    [:created, :deleted, :updated].each do |type|
      new_result[type].each do |new_entry|
        old_entry = old_result[type].select{|x| x[:identifier] == new_entry[:identifier]}
        if old_entry.empty?
          puts colourize("old: Cannot find!!\nnew: #{new_entry}", "blue")
        else
          [:identifier, :label, :notation, :id, :last_id].each do |x|
            puts colourize("identififer: #{new_entry[:identifier]}\nold: #{old_entry.first[x]}\nnew: #{new_entry[x]}", "blue") if old_entry.first[x] != new_entry[x]
          end
        end
      end
    end
  end

  def file_compare(index)
    compare("changes_cdu_expected_#{index}.yaml", "differences_expected_#{index}.yaml")
  end

  describe Thesaurus::Difference do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
    end

    after :all do
    end

    it "difference I" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V4#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_1.yaml", equate_method: :hash_equal)
      file_compare(1)
    end

    it "difference II" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V7#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V9#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_2.yaml", equate_method: :hash_equal)
      file_compare(2)
    end

    it "difference III" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V13#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V16#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_3.yaml", equate_method: :hash_equal)
      file_compare(3)
    end

    it "difference IV" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V56#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_4.yaml", equate_method: :hash_equal)
      file_compare(4)
    end

    it "difference V" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_5.yaml", equate_method: :hash_equal)
      file_compare(5)
    end

    it "difference VI" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V47#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V50#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_6.yaml", equate_method: :hash_equal)
      file_compare(6)
    end

    it "difference VII" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V61#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_7.yaml", equate_method: :hash_equal)
      file_compare(7)
    end

    it "difference VIII" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V61#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_8.yaml", equate_method: :hash_equal)
      file_compare(8)
    end

    it "difference IX" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V39#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_9.yaml", equate_method: :hash_equal)
      file_compare(9)
    end

    it "difference X" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V56#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V60#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_10.yaml", equate_method: :hash_equal)
      file_compare(10)
    end

    it "difference XI" do
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
      other = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      result = th.differences(other)
      check_file_actual_expected(result, sub_dir, "differences_expected_11.yaml", equate_method: :hash_equal)
      file_compare(11)
    end

  end

end
