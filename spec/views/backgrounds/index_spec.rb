require 'rails_helper'

describe 'backgrounds/index.html.erb' do

  include UiHelpers

  it 'displays background job details correctly' do
    
    x = Time.now
    timestamp = Timestamp.new(x).to_datetime
    jobs = []
    job = Background.new
    job.update(description: "Job 1", status: "Reading file.", started: x, percentage: 50, complete: false)
    jobs << job
    job = Background.new
    job.update(description: "Job 2", status: "Finished", started: x, percentage: 100, complete: true, completed: x)
    jobs << job
    assign(:jobs, jobs)

    render

    expect(rendered).to have_content("Index: Background Jobs")
    #ui_check_breadcrumb("Background", "", "", "")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'Job 1')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Reading file')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: timestamp)
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '50')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: 'Job 2')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'Finished')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: timestamp)
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: '100')
		expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(5)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(6)", text: timestamp)

  end

  it 'check glyphicon'

end