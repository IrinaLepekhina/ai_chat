# app/components/ai_integration_component.rb

# The AiIntegrationComponent class provides an integration point for AI services in the application.
# It utilizes the ConversationAiHandler to generate AI responses based on conversations and content.
class AiIntegrationComponent
  include Loggable

  def initialize
    @language_service = EmbeddingsAdapter.new(OpenAiService.new)
    @redis_storage_service = RedisStorageService.new(@language_service)
    @vector_similarity_service = VectorSimularityService.new(@redis_storage_service)
  end

  def generate_ai_response(conversation, content)
    log_info("Beginning generation of AI response.") 

    conversation_ai_handler = ConversationAiHandler.new(@language_service, @vector_similarity_service, @redis_storage_service)
    conversation_ai_handler.generate_ai_response(content)
  end
end