FactoryBot.define do
  factory :product do
    sequence(:title) { |n| "Product #{n}" }
    description { "description" }
    price_init { "200.6" }
    # category_id { Category.all.sample.id }

    # subfactory
    factory :by_weight_product do
      price_type { :by_weight }
    end

    factory :per_unit_product do
      price_type { :per_unit }
    end
  end
end
