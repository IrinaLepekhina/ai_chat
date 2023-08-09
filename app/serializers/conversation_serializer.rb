# app/serializers/api/v1/conversation_serializer.rb

class ConversationSerializer < ApplicationSerializer
  attributes :id, :user_id, :created_at

  has_many :chat_entries
  has_many :ai_responses
end
