require 'rails_helper'

describe 'forms/history.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/forms"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_dm1.ttl", "form_example_vs_baseline_new.ttl",
    "form_example_general.ttl", "CT_ACME_V1.ttl", "BC.ttl", "BCT.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..43)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
  end

  it 'displays the form history' do

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(edit?: true, destroy?: true)

    params = {:identifier => "DM1 01", :scope => IsoRegistrationAuthority.owner.ra_namespace}
    forms = Form.history(params)
    assign(:forms, forms)
    assign(:identifier, "DM1 01")

    render

  	#puts response.body

    expect(rendered).to have_content("History: DM1 01")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '0.0.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Demographics')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'DM1 01')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'ACME')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(11)", text: 'Candidate')

    expect(rendered).to have_link "Changes"

  end

end
