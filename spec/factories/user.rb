FactoryGirl.define do
    # Define a basic devise user.
    factory :user do
        email "example@example.com"
        password "example1234"
        password_confirmation "example1234"
    end
end