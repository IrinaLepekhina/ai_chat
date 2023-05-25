class ProductSerializer < ApplicationSerializer
  attribute :title, key: :product_title
  # attributes :id, :category_title

  # def category_title
  #   object.category.title
  # end
end
