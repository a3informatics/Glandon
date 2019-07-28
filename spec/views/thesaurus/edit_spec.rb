require 'rails_helper'

describe 'thesauri/edit.html.erb', :type => :view do

  include ViewHelpers
  include UserAccountHelpers
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "views/thesaurus/edit"
  end

  before :all do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
    load_files(schema_files, data_files)
    @user = User.create :email => "user@assero.co.uk", :password => "cHangeMe14%", :name => "User Fred"
  end

  after :all do
    @user.destroy
  end

  before :each do
    NameValue.destroy_all
  end

  after :each do
    NameValue.destroy_all
  end

  it 'new panel, flat, generted' do 

    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    local_configuration = {scheme_type: :flat, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}}
    expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).and_return(local_configuration)

    allow(view).to receive(:current_user).and_return(@user)

    token = Token.new
    token.id = "1234"
    assign(:thesaurus, Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1")))
    assign(:parent_identifier, "")
    assign(:token, token)
    assign(:close_path, "")
    assign(:referrer_path, "")

    render

  #puts response.body

    expect(rendered).to have_content("CDISC Extensions CDISC EXT (V, 1, Standard)")
    expect(rendered).to have_content("An identifier will be automatically generated")

  end

  it 'new panel, flat, entered' do 

    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    local_configuration = {scheme_type: :flat, parent: {entered: true}}
    expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).twice.and_return(local_configuration)

    allow(view).to receive(:current_user).and_return(@user)

    token = Token.new
    token.id = "1234"
    assign(:thesaurus, Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1")))
    assign(:parent_identifier, "")
    assign(:token, token)
    assign(:close_path, "")
    assign(:referrer_path, "")

    render

  #puts response.body

    expect(rendered).to have_content("CDISC Extensions CDISC EXT (V, 1, Standard)")
    expect(rendered).to have_content("Identifier:")
    expect_button_to_be_visible("tnp_identifier")
    #expect_button_to_not_be_visible(id)

  end

  it 'new panel, hierarchical, entered' do 

    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    local_configuration = {scheme_type: :hierarchical, parent: {entered: true}}
    expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).twice.and_return(local_configuration)

    allow(view).to receive(:current_user).and_return(@user)

    token = Token.new
    token.id = "1234"
    assign(:thesaurus, Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1")))
    assign(:parent_identifier, "")
    assign(:token, token)
    assign(:close_path, "")
    assign(:referrer_path, "")

    render

  #puts response.body

    expect(rendered).to have_content("CDISC Extensions CDISC EXT (V, 1, Standard)")
    expect(rendered).to have_content("Identifier:")
    expect_button_to_be_visible("tnp_identifier")

  end

  it 'new panel, hierarchical, entered, non empty parent' do 

    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    local_configuration = {scheme_type: :hierarchical, parent: {entered: true}}
    expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).twice.and_return(local_configuration)

    allow(view).to receive(:current_user).and_return(@user)

    token = Token.new
    token.id = "1234"
    assign(:thesaurus, Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1")))
    assign(:parent_identifier, "XXX")
    assign(:token, token)
    assign(:close_path, "")
    assign(:referrer_path, "")

    render

  #puts response.body

    expect(rendered).to have_content("CDISC Extensions CDISC EXT (V, 1, Standard)")
    expect(rendered).to have_content("Identifier:")
    expect(rendered).to have_content("XXX")
    expect_button_to_be_visible("tnp_identifier")

  end

  it 'new panel, flat, entered, non empty parent' do 

    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    local_configuration = {scheme_type: :flat, parent: {entered: true}}
    expect(Thesaurus::ManagedConcept).to receive(:identification_configuration).twice.and_return(local_configuration)

    allow(view).to receive(:current_user).and_return(@user)

    token = Token.new
    token.id = "1234"
    assign(:thesaurus, Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1")))
    assign(:parent_identifier, "XXX")
    assign(:token, token)
    assign(:close_path, "")
    assign(:referrer_path, "")

    render

  #puts response.body

    expect(rendered).to have_content("CDISC Extensions CDISC EXT (V, 1, Standard)")
    expect(rendered).to have_content("Identifier:")
    expect_button_to_be_visible("tnp_identifier")

  end

end