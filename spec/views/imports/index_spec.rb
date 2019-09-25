require 'rails_helper'

describe 'imports/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/imports"
  end

  class Owner

    def short_name
      return "OWNER"
    end

  end

  class Other

    def self.owner
      return Owner.new
    end

    def self.configuration
      {identifier: "XXX"}
    end

  end

  class ImportTest < Import

    def import(params)
    end

    def self.configuration
      {
        description: "Import of Something",
        parent_klass: Other,
        reader_klass: Excel::AdamIgReader,
        import_type: :TYPE,
        sheet_name: :main,
        version_label: :semantic_version,
        label: "XXX Implementation Guide"
      }
    end

    def configuration
      self.class.configuration
    end

  end

  def simple_import(identifier)
    item = ImportTest.new
    params = {files: ["#{identifier}.txt"], auto_load: false, identifier: identifier, file_type: "1"}
    item.create(params)
    return item
  end

  before :each do
    ["AAA", "BBB"].each{|x| simple_import(x)}
  end

  it 'displays the form history' do

    assign(:items, Import.all)
    render

	#puts response.body

    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'OWNER')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'AAA')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: 'AAA.txt')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'OWNER')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'BBB')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: 'BBB.txt')
    expect(rendered).to have_link "Delete All"
  end

end
