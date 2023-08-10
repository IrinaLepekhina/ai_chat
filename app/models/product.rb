# Product is an ActiveRecord model representing a product available for creating in the application.


class Product < ApplicationRecord
  enum price_type: { per_unit: 0, by_weight: 1 }

  validates :title, :price_type, :price_init, presence: true
  validates :title, uniqueness: true
  validates :price_init, numericality: { greater_than: 0 }

  paginates_per 10
end
