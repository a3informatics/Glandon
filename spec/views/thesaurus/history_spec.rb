require 'rails_helper'

describe 'thesauri/history.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/cdisc_terms"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
  end

  it 'displays the history panel and comments panel' do

    def view.policy(name)
      # Do nothing
    end

    ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))

    assign(:thesaurus, ct)
    assign(:identifier, ct.has_identifier.identifier)
    assign(:scope_id, ct.scope.id)

    ApplicationController.any_instance.stub(:normalize_versions){[50]}

    render

  	#puts response.body

    expect(rendered).to have_content("Version History of 'CT'")
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Version')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Last Change Date')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(3)", text: 'Owner')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(4)", text: 'Identifier')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(5)", text: 'Label')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(6)", text: 'Version Label')

    # expect(rendered).to have_content("Comments By Version")
    # expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Version')
    # expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Creation Date')
    # expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(3)", text: 'Last Change Date')
    # expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(4)", text: 'Description')
    # expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(5)", text: 'Comments')
    # expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(6)", text: 'References')

  end

end
