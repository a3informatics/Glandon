require 'rails_helper'

describe Reports::CrfReport do

  include DataHelpers
  include ReportHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/reports"
  end

  before :all do
    clear_triple_store
  end

  it "thesaurus impact report" # do
  #   user = User.create email: "wicked@example.com", password: "Changeme1#"
  #   report = Reports::ThesaurusImpactReport.new
  #   thesaurus = Thesaurus.new
  # 	results = read_yaml_file(sub_dir, "thesaurus_impact_report_1.yaml")
  #   html = report.create(thesaurus, results, user)
  # #write_text_file_2(html, sub_dir, "thesaurus_impact_report_1.txt")
  #   expected = read_text_file_2(sub_dir, "thesaurus_impact_report_1.txt")
  #   run_at_1 = extract_run_at(expected)
  #   run_at_2 = extract_run_at(html)
  #   html.sub!(run_at_2, run_at_1) # Need to fix the run at date and time for the comparison
  #   path_to_proj_1 = extract_path(expected)
  #   path_to_proj_2 = Rails.root.to_s
  #   expected.sub!(path_to_proj_1, path_to_proj_2)
  #   expect(html).to eq(expected)
  # end

end
