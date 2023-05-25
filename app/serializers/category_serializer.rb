class CategorySerializer < ApplicationSerializer
  attributes :id, :title

  has_many :products

  class ProductSerializer < ApplicationSerializer
    attribute :title, key: :product_title
    attributes :id
  end
end
