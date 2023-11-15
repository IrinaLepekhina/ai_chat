# app/services/embeddings_adapter.rb

class EmbeddingsAdapter
  include Loggable

  def initialize(language_service)
    @language_service = language_service
  end

  def get_embeddings(content:)
    @language_service.get_embeddings(content: content)
  end

  def generate_response(prompt:, content:)
    log_info("through EmbeddingsAdapter")
    result = @language_service.generate_response(prompt: prompt, content: content)
    log_info("Successfully generated response")
    result
  end
end