class Prompt < ApplicationRecord
  validates :content, presence: true
  has_many  :ai_responses, dependent: :restrict_with_error 

  paginates_per 10
end