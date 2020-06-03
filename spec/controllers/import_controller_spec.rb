require 'rails_helper'

describe ImportsController do

  include DataHelpers
  include PauseHelpers

  describe "import as content admin" do

    login_content_admin

    def sub_dir
      return "controllers/import"
    end

    before :each do
      clear_triple_store
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

      Import.delete_all
      @b1 = Background.create(description: "job 1", complete: true, percentage: 100, status: "Doing something", started: Time.now,
        completed: Time.now)
      @i1 = Import.create(input_file: "", output_file: "", error_file: "", success_path: "", error_path: "", success: true,
        background_id: @b1.id, token_id: nil, auto_load: false, identifier: "XXX", owner: "YYY", file_type: 0)
      @i2 = Import.create(input_file: "", output_file: "", error_file: "", success_path: "", error_path: "", success: true,
        background_id: @b1.id, token_id: nil, auto_load: false, identifier: "XXX", owner: "YYY", file_type: 0)
      @i3 = Import.create(input_file: "", output_file: "", error_file: "", success_path: "", error_path: "", success: true,
        background_id: @b1.id, token_id: nil, auto_load: false, identifier: "XXX", owner: "YYY", file_type: 0)
    end

    after :each do
    end

    it "index" do
      get :index
      expect(response.code).to eq("200")
      expect(response).to render_template("index")
    end

    it "index, json" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(assigns(:items).count).to eq(3)
      expect(assigns(:items).map{|j| j.id}).to match_array([@i1.id, @i2.id, @i3.id])
      expect(response.code).to eq("200")
      x = JSON.parse(response.body).deep_symbolize_keys
      expect(x[:data].map{|j| j[:id]}).to match_array([@i1.id, @i2.id, @i3.id])
    end

    it "show" do
      get :show, params:{id: @i1.id}
      expect(assigns(:import).id).to eq(@i1.id)
      expect(response.code).to eq("200")
      expect(response).to render_template("show")
    end

    it "show, json" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, params:{id: @i1.id}
      expect(response.code).to eq("200")
      x = JSON.parse(response.body).deep_symbolize_keys
      expect(x[:data].keys).to match_array([:import, :job, :errors])
      expect(x[:data][:import][:id]).to eq(@i1.id)
      expect(x[:data][:job][:id]).to eq(@b1.id)
      expect(x[:data][:job][:description]).to eq(@b1.description)
    end

    it "destroy" do
      delete :destroy, params:{id: @i2.id}
      expect(Import.all.count).to eq(2)
      expect(Import.all.map{|j| j.id}).to match_array([@i1.id, @i3.id])
      expect(response.code).to eq("200")
    end

    it "destroy_multiple all" do
      delete :destroy_multiple, params:{imports: {items: "all"}}
      expect(Import.all.count).to eq(0)
      expect(response.code).to eq("200")
    end

    it "list" do
      get :list
      expect(assigns(:items)).to match_array(Rails.configuration.imports[:imports].values)
      expect(response.code).to eq("200")
      expect(response).to render_template("list")
    end

  end

  describe "Reader User" do

    login_reader

    it "index" do
      get :index
      expect(response).to redirect_to("/")
    end

    it "destroy" do
      delete :destroy, params:{id: 1}
      expect(response).to redirect_to("/")
    end

    it "destroy_multiple" do
      delete :destroy_multiple
      expect(response).to redirect_to("/")
    end

  end

  describe "Unauthorized User" do

    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "destroy" do
      delete :destroy, params:{id: 1}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "destroy_multiple" do
      delete :destroy_multiple
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end
