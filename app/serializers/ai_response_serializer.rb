# app/serializers/api/v1/ai_response_serializer.rb

class AiResponseSerializer <  ApplicationSerializer
  attributes :id, :conversation_id, :chat_entry_id, :content, :created_at
end
