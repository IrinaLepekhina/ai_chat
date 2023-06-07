# app/services/conversation_ai_handler.rb

# The ConversationAiHandler class handles AI-based conversation processing.
# Generates an AI response based on the provided content.
class ConversationAiHandler
  def initialize(openai_service, cosine_similarity_service, csv_storage_service)
    @openai_service = openai_service
    @cosine_similarity_service = cosine_similarity_service
    @csv_storage_service = csv_storage_service
  end

  def generate_ai_response(content)
    # Get the embedding for the provided content
    question_embedding = @openai_service.get_embeddings(content)
    
    # Find the most similar text based on the question embedding
    original_text = find_most_similar_text(question_embedding)
    
    # Generate the prompt using the original text and content
    prompt = generate_prompt(original_text, content)
    
    # Generate an AI response based on the prompt
    ai_response = @openai_service.generate_response(prompt)
    
    ai_response
  end
  
  private

  def find_most_similar_text(question_embedding)
    # Retrieve the embeddings from the storage service
    embeddings = @csv_storage_service.retrieve_embeddings
    
    # Calculate the similarity between the question embedding and each text embedding
    similarity_array = embeddings.map do |text_embedding|
      calculate_similarity(question_embedding, text_embedding)
    end
    
    # Find the index of the maximum similarity
    index_of_max = find_index_of_max_similarity(similarity_array)
    
    # Find the original text at the corresponding index
    original_text = find_text_at_index(index_of_max)

    original_text
  end

  def calculate_similarity(embedding1, embedding2)
    # Calculate the cosine similarity between two embeddings using the similarity service
    @cosine_similarity_service.calculate_similarity(embedding1, embedding2)
  end
  
  def find_index_of_max_similarity(similarity_array)
    # Find the index of the maximum value in the similarity array
    similarity_array.index(similarity_array.max)
  end
  
  def find_text_at_index(index)
    # Find the text at the specified index in the storage service
    @csv_storage_service.find_text_at_index(index)
  end
  
  def generate_prompt(original_text, content)
    <<~PROMPT
      You are an AI assistant. You work for Planta_Tony which is a water store located in Guadalajara.
      You will be asked questions from a customer and will answer in a helpful and friendly manner.

      You will be provided company information from Planta_Tony under the [Article] section. The customer question
      will be provided under the [Content] section. You will answer the customer's questions based on the article.
      If the user's question is not answered by the article, you will respond with "I'm sorry, I don't know."

      [Article]
      #{original_text}

      [Content]
      #{content}
    PROMPT
  end
end
