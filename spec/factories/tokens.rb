FactoryGirl.define do
  factory :token do
    locked_at "2016-12-01 17:49:17"
    refresh_count 1
    item_uri "MyString"
    item_info "MyString"
    user_id 1
  end
end
