# app/models/ai_response.rb

# Represents an ai_response within a conversation and chat_entry.
class AiResponse < ApplicationRecord
  belongs_to :conversation
  belongs_to :chat_entry

  validates :conversation, presence: true
  validates :content, presence: true

  def user
    conversation.user
  end
end
