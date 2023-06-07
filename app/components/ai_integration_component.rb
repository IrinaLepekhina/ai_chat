# app/components/ai_integration_component.rb

# The AiIntegrationComponent class provides an integration point for AI services in the application.
# It utilizes the ConversationAiHandler to generate AI responses based on conversations and content.
class AiIntegrationComponent
  def initialize
    @openai_service = OpenAiService.new
    @cosine_similarity_service = CosineSimilarityService.new

    # Instantiate the CSV storage service with the path to the embeddings CSV file
    @csv_storage_service = CsvStorageService.new("#{Rails.root}/app/data/embeddings.csv")

    # Instantiate the ConversationAiHandler with the required services
    @conversation_ai_handler = ConversationAiHandler.new(@openai_service, @cosine_similarity_service, @csv_storage_service)
  end

  # Delegate the generation of the AI response to the ConversationAiHandler
  def generate_ai_response(conversation, content)
    @conversation_ai_handler.generate_ai_response(content)
  end
end