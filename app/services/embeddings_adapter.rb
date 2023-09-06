# app/services/embeddings_adapter.rb

class EmbeddingsAdapter
  include Loggable

  def initialize(language_service)
    @language_service = language_service
  end

  def get_embeddings(content)
    @language_service.get_embeddings(content)
  end

  def generate_response(prompt)
    log_info("Generating response based on provided prompt")
    result = @language_service.generate_response(prompt)
    log_info("Successfully generated response")
    result
  end
end