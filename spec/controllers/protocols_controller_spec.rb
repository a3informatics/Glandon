require 'rails_helper'

describe ProtocolsController do

  include DataHelpers
  include UserAccountHelpers
  include ControllerHelpers

  def sub_dir
    return "controllers/protocols"
  end

  describe "Authorized User" do

    login_curator

    before :all do
      load_files(schema_files, [])
      load_test_file_into_triple_store("transcelerate.nq.gz")
    end

    it "show" do
      p = Protocol.find_minimum(Uri.new(uri: "http://www.transceleratebiopharmainc.com/LY246708/V1#PR"))
      get :show, id: p.id
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "show_expected.yaml", equate_method: :hash_equal)
    end

  end

end
