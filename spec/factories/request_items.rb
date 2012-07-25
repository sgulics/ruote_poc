# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :request_item do
    state "MyString"
    error "MyString"
    service1_id 1
    service2_id 1
  end
end
