FactoryBot.define do
  factory :meal do
    sequence(:title) { |n| "Meal #{n}" }
    description { "description" }
    price_init { "200.6" }
    # category_id { Category.all.sample.id }

    # subfactory
    factory :by_weight_meal do
      price_type { :by_weight }
    end

    factory :per_unit_meal do
      price_type { :per_unit }
    end
  end
end
