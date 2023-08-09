# app/services/embeddings_adapter.rb
class EmbeddingsAdapter
  def initialize(language_service)
    @language_service = language_service
  end

  def get_embeddings(content)
    @language_service.get_embeddings(content)
  end

  def generate_response(prompt)
    @language_service.generate_response(prompt)
  end
end