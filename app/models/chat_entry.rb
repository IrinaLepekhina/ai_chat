# app/models/chat_entry.rb

# Represents a chat entry within a conversation.
class ChatEntry < ApplicationRecord
  belongs_to :conversation

  validates :conversation, presence: true
  validates :content, presence: true

  def user
    conversation.user
  end
end
