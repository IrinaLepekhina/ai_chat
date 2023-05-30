FactoryBot.define do
  factory :conversation do
    user { User.all.sample.id }
  end
end
