# app/services/conversation_ai_handler.rb

# The ConversationAiHandler class handles AI-based conversation processing.
# Generates an AI response based on the provided content.
class ConversationAiHandler
  def initialize(language_service, vector_similarity_service, redis_storage_service)
    @language_service = language_service
    @vss = vector_similarity_service
    @redis = redis_storage_service
  end

  def generate_ai_response(content)
    question_embedding = 
      @language_service.get_embeddings(content)   #JSON.parse(File.read('spec/fixtures/question_embedding.json')) 

    store_query_in_redis(question_embedding, content)
    
    original    = find_most_similar_text_and_text_id(question_embedding)
    ai_response = generate_ai_response_from_prompt(original[:text], content)
    
    { content: ai_response, original_text_id: original[:text_id] }
  end
  
  private
  
  def store_query_in_redis(question_embedding, content)
    query_vector = { "text_id": "chat_entry_content", "text_vector": question_embedding, "content": content }
    @redis.set_query(query_vector)
  end

  def find_most_similar_text_and_text_id(question_embedding)
    @vss.query_original_text(question_embedding)
  end
  
  def generate_ai_response_from_prompt(original_text, content)
    prompt = generate_prompt(original_text, content)
    @language_service.generate_response(prompt)   # 'Hi, there'
  end
  
  def generate_prompt(original_text, content)
     <<~PROMPT
      You are an AI assistant. You work for Planta_chat which is a factory located in city N.
      You will be asked questions from a customer and will answer in a helpful and friendly manner.

      You will be provided company information  under the [Article] section. The customer question
      will be provided under the [Content] section. You will answer the customer's questions based on the article.
      If the user's question is not answered by the article, you will respond with "I'm sorry, I don't know."

      [Article]
      #{original_text}

      [Content]
      #{content}
    PROMPT
  end
end
