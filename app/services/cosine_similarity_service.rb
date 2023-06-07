# app/services/cosine_similarity_service.rb

# The CosineSimilarityService class calculates the cosine similarity between two vectors.
class CosineSimilarityService
  def calculate_similarity(question_embedding, text_embedding)
    cosine_similarity(question_embedding, text_embedding)
  end

  private

  # Calculates the cosine similarity between the question embedding and text embedding.
  def cosine_similarity(question_embedding, text_embedding)
    if !question_embedding.is_a?(Array) || !text_embedding.is_a?(Array)
      return 'Error: Both arguments must be arrays'
    else
      dot_product = question_embedding.zip(text_embedding).map { |x, y| x * y }.sum
      norm1 = Math.sqrt(question_embedding.map { |x| x**2 }.sum)
      norm2 = Math.sqrt(text_embedding.map { |x| x**2 }.sum)
      return dot_product / (norm1 * norm2)
    end
  end
end

