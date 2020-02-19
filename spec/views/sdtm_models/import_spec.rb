require 'rails_helper'

describe 'sdtm_models/import.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/sdtm_model"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "sdtm_model_and_ig.ttl"]
    load_files(schema_files, data_files)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
  end

  it 'displays the form, import and files' do

    files = [ "a.xlsx", "b.xlsx", "c.xlsx" ]
    next_version = SdtmModel.all.last.next_version

    assign(:sdtm_class_model, SdtmModel.new)
    assign(:cdiscTerm, CdiscTerm.new)
    assign(:files, files)
    assign(:next_version, next_version)

    render

  #puts response.body

    expect(rendered).to have_content("Import CDISC SDTM Model Version")
    expect(rendered).to have_xpath("//input[@id = 'sdtm_model_version' and @value = '4']")
    expect(rendered).to have_selector("select option", text: 'a.xlsx')
    expect(rendered).to have_selector("select option", text: 'b.xlsx')
    expect(rendered).to have_selector("select option", text: 'c.xlsx')

    expect(rendered).to have_button "Create"
    expect(rendered).to have_link "Close"

  end

end
