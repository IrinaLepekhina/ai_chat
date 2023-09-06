# app/serializers/api/v1/conversation_serializer.rb

class ConversationSerializer < ApplicationSerializer
  attributes :id, :user_id, :created_at, :last_chat_entry

  def last_chat_entry
    object.chat_entries&.last
  end
end
