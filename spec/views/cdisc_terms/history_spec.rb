require 'rails_helper'

describe 'cdisc_terms/history.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/cdisc_terms"
  end

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
  end

  it 'displays the form, import and files' do

    def view.policy(name)
      # Do nothing
    end

    item = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V2#TH"))
    assign(:ct, item)
    assign(:cdisc_term_id, item.id)
    assign(:scope_id, item.scope.id)
    assign(:identifier, item.has_identifier.identifier)

    render

  	#puts response.body

    expect(rendered).to have_content("Item History")
    expect(rendered).to have_content("Controlled Terminology")
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Version')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Owner')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(3)", text: 'Identifier')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(4)", text: 'Label')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(5)", text: 'Version Label')

    expect(rendered).to have_link "View Changes"
    expect(rendered).to have_link "View Submission value changes"

  end

end
