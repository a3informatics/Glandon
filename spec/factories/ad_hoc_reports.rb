FactoryGirl.define do
  factory :ad_hoc_report do
    label "MyString"
    sparql_file "MyString"
    results_file "MyString"
    last_run "2017-01-18 15:16:49"
    status 1
    background_id 1
  end
end
