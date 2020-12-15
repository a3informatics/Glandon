require 'rails_helper'

describe IsoManagedV2::Dependencies do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers

	def sub_dir
    return "models/iso_managed_v2/im_custom_properties"
  end

  class IMDLayer1 < IsoManagedV2
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority"

    def self.dependency_paths
      []
    end

  end

  class IMDLayer2 < IsoManagedV2
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority"
    object_property :ra_namespace, cardinality: :many, model_class: "IMDLayer1"

    def self.dependency_paths
      ["<http://www.assero.co.uk/Test#raNamespace>"]
    end
    
  end

  class IMDLayer3 < IsoManagedV2
    configure rdf_type: "http://www.assero.co.uk/Test#RegistrationAuthority2"
    object_property :ra_namespace2, cardinality: :many, model_class: "IMDLayer2"

    def self.dependency_paths
      ["<http://www.assero.co.uk/Test#raNamespace2>"]
    end
    
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
      expect{IsoManagedV2.dependency_paths}.to raise_error(Errors::ApplicationLogicError, "Method not implemented for class.")
    end

    it "get dependencies" do
      results = {}
      create_data
      [@item_1, @item_2, @item_3, @item_4, @item_5, @item_6, @item_7].each do |x|
        results[x.uri.to_s] = x.dependency_required_by.map{|x| x.to_h}
      end
      check_file_actual_expected(results, sub_dir, "dependency_required_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end
