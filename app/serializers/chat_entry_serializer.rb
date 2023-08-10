# app/serializers/api/v1/chat_entry_serializer.rb

class ChatEntrySerializer < ApplicationSerializer
  attributes :id, :conversation_id, :content, :created_at, :ai_response_content

  def ai_response_content
    object.ai_response&.content
  end
end
