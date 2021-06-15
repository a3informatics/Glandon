require 'rails_helper'

describe IsoManagedV2::Dependencies do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers
  include IsoManagedHelpers

	def sub_dir
    return "models/iso_managed_v2/im_custom_properties"
  end

  class IMDLayer1 < IsoManagedV2
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority3"

    def self.dependency_paths
      []
    end

  end

  class IMDLayer2 < IsoManagedV2
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority3"
    object_property :ra_namespace3, cardinality: :many, model_class: "IMDLayer1"

    def self.dependency_paths
      ["<http://www.assero.co.uk/Test#raNamespace>"]
    end
    
  end

  class IMDLayer3 < IsoManagedV2
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority4"
    object_property :ra_namespace4, cardinality: :many, model_class: "IMDLayer2"

    def self.dependency_paths
      ["<http://www.assero.co.uk/Test#raNamespace2>"]
    end
    
  end
  
  class IMDLayer4 < IsoManagedV2
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority3"
  end

  class IMDLayer5 < IsoManagedV2
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority5"

  end

  def create_data
    @item_1 = IMDLayer1.create(identifier: "ITEM1")
    @item_7 = IMDLayer1.create(identifier: "ITEM7")
    @item_2 = IMDLayer2.create(identifier: "ITEM2", ra_namespace: [@item_1.uri])
    @item_3 = IMDLayer3.create(identifier: "ITEM3", ra_namespace2: [@item_2.uri])
    @item_4 = IMDLayer1.create(identifier: "ITEM4")
    @item_5 = IMDLayer2.create(identifier: "ITEM5", ra_namespace: [@item_4.uri, @item_7.uri])
    @item_6 = IMDLayer3.create(identifier: "ITEM6", ra_namespace2: [@item_2.uri, @item_5.uri])
  end


  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :each do
    end

    it "error no paths defined" do
      expect{IsoManagedV2.dependency_paths}.to raise_error(Errors::ApplicationLogicError, "Method not implemented for class IsoManagedV2.")
    end

    it "error no paths defined" do
      expect{IMDLayer5.dependency_paths}.to raise_error(Errors::ApplicationLogicError, "Method not implemented for class IMDLayer5.")
    end

    it "error no configuration for class" do
      instance = IMDLayer4.new
      result = instance.dependency_required_by
      expect(result).to eq([])
    end

    it "error no models for class" do
      instance = IMDLayer3.new
      result = instance.dependency_required_by
      expect(result).to eq([])
    end

    it "get dependencies" do
      results = {}
      create_data
      [@item_1, @item_2, @item_3, @item_4, @item_5, @item_6, @item_7].each_with_index do |x, index_1|
        results = x.dependency_required_by
        results.each_with_index do |x, index_2|
          filename = "dependency_required_expected_#{index_1 + 1}#{index_2 + 1}.yaml"
          fix_dates(x, sub_dir, filename, :creation_date, :last_change_date)
          check_file_actual_expected(x.to_h, sub_dir, filename, equate_method: :hash_equal)
        end
      end
    end

  end

end
