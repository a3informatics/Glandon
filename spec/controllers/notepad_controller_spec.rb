require 'rails_helper'

describe NotepadsController do

  include DataHelpers
  
  describe "Authorized User" do
  	
    login_curator

    it "clears triple store and loads test data" do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCTerm.ttl")
      load_data_file_into_triple_store("MDRIdentificationACME.ttl")
      load_test_file_into_triple_store("CT_V34.ttl")
      clear_iso_concept_object
    end

    it "index notepad" do
      Notepad.create :uri_id => "ID1", :uri_ns => "http://www.example/com/term", :identifier => "A1", :useful_1 => "NOT1", :useful_2 => "Label1", :user_id => @user.id, :note_type => 0
      Notepad.create :uri_id => "ID2", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT2", :useful_2 => "Label2", :user_id => @user.id, :note_type => 0
      Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => @user.id, :note_type => 0
      notes = Notepad.all
      get :index
      expect(assigns(:items).to_json).to eq(notes.to_json)
      expect(response).to render_template("index")
    end

    it "index terminology as JSON" do
      Notepad.create :uri_id => "ID1", :uri_ns => "http://www.example/com/term", :identifier => "A1", :useful_1 => "NOT1", :useful_2 => "Label1", :user_id => @user.id, :note_type => 0
      Notepad.create :uri_id => "ID2", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT2", :useful_2 => "Label2", :user_id => @user.id, :note_type => 0
      Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => @user.id, :note_type => 0
      request.env['HTTP_ACCEPT'] = "application/json"
      notes = Notepad.all
      get :index_term
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{\"count\":3,\"data\":#{notes.to_json}}")
    end

    it "index terminology as JSON, no entries" do
      request.env['HTTP_ACCEPT'] = "application/json"
      notes = []
      get :index_term
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{\"count\":0,\"data\":[]}")
    end

    #it "index terminology as HTML" do
    #  Notepad.create :uri_id => "ID1", :uri_ns => "http://www.example/com/term", :identifier => "A1", :useful_1 => "NOT1", :useful_2 => "Label1", :user_id => @user.id, :note_type => 0
    #  Notepad.create :uri_id => "ID2", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT2", :useful_2 => "Label2", :user_id => @user.id, :note_type => 0
    #  Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => @user.id, :note_type => 0
    #  notes = Notepad.all
    #  get :index_term
    #  expect(assigns(:results).to_json).to eq({:count => 3, :data => notes.to_json})
    #  expect(response).to render_template("index")
    #end

    it "creates a notepad entry" do
      post :create_term, notepad: { :item_id => "CLI-C100133_C100387", :item_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V34" }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{\"count\":1}")
    end

    it "creates multiple notepad entries" do
      post :create_term, notepad: { :item_id => "CLI-C100133_C100387", :item_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V34" }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{\"count\":1}")
      post :create_term, notepad: { :item_id => "CLI-C100133_C100388", :item_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V34" }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{\"count\":2}")
    end

    it "creates a notepad entry - fails" do
      post :create_term, notepad: { :item_id => "CLI-C100133_C100387x", :item_ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V34" }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")  
    end

    
    it "deletes all terminology entries" do
      user1 = User.create :email => "user1@example.com", :password => "12345678"
      user2 = User.create :email => "user2@example.com", :password => "12345678"
      Notepad.create :uri_id => "ID1", :uri_ns => "http://www.example/com/term", :identifier => "A1", :useful_1 => "NOT1", :useful_2 => "Label1", :user_id => @user.id, :note_type => 0
      Notepad.create :uri_id => "ID2", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT2", :useful_2 => "Label2", :user_id => @user.id, :note_type => 0
      Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => @user.id, :note_type => 0
      Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => user1.id, :note_type => 0
      Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => user2.id, :note_type => 0
      delete :destroy_term
      items = Notepad.where(:user_id => @user.id)
      items1 = Notepad.where(:user_id => user1.id)
      items2 = Notepad.where(:user_id => user2.id)
      expect(items.count).to eq(0)
      expect(items1.count).to eq(1)
      expect(items2.count).to eq(1)
      expect(response).to redirect_to("/notepads")
    end

    it "deletes a terminology entry" do
      Notepad.create :uri_id => "ID1", :uri_ns => "http://www.example/com/term", :identifier => "A1", :useful_1 => "NOT1", :useful_2 => "Label1", :user_id => @user.id, :note_type => 0
      notepad = Notepad.create :uri_id => "ID2", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT2", :useful_2 => "Label2", :user_id => @user.id, :note_type => 0
      Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => @user.id, :note_type => 0
      delete :destroy, :id => notepad.id
      items = Notepad.where(:user_id => @user.id)
      expect(items.count).to eq(2)
      expect(response).to redirect_to("/notepads")
    end

  end

  describe "Unauthorized User" do
    
    login_reader

    it "prevents access to a reader, index" do
      get :index
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, index_term" do
      get :index_term
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, create_term" do
      post :create_term
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, destroy_term" do
      delete :destroy_term
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, destroy" do
      notepad = Notepad.create :uri_id => "ID3", :uri_ns => "http://www.example/com/term", :identifier => "A3", :useful_1 => "NOT3", :useful_2 => "Label3", :user_id => @user.id, :note_type => 0
      delete :destroy, :id => notepad.id
      expect(response).to redirect_to("/")
    end

  end

end