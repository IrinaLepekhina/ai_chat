# app/models/conversation.rb

# Represents a conversation between a user and the AI.
class Conversation < ApplicationRecord
  belongs_to :user
  has_many :chat_entries, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :ai_responses, -> { order(created_at: :desc) }, dependent: :destroy
  validates :user, presence: true

  validates_associated :chat_entries

  accepts_nested_attributes_for :chat_entries#, allow_destroy: true, reject_if: :reject_chat_entries

  # @return [Boolean] Whether to reject the chat entry or not.
  def reject_chat_entries(attributes)
    attributes['content'].blank?
  end

  # Adds a new message to the conversation.
  #
  # @param content [String] The content of the message.
  # @return [ChatEntry] The created chat entry.
  def add_message(content)
    chat_entries.create(content: content)
  end
end
