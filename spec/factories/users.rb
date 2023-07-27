FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    nickname { Faker::Alphanumeric.alphanumeric(number: 10, min_alpha: 3) }
    password { Faker::Internet.password }
  end
end