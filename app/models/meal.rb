# Meal is an ActiveRecord model representing a meal available for creating in the application.


class Meal < ApplicationRecord
  enum price_type: { per_unit: 0, by_weight: 1 }

  validates :title, :price_type, :price_init, presence: true
  validates :price_init, numericality: { greater_than: 0 }

  paginates_per 10
end
