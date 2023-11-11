# app/services/conversation_ai_handler.rb

# The ConversationAiHandler class handles AI-based conversation processing.
# Generates an AI response based on the provided content.
class ConversationAiHandler
  include Loggable
  def initialize(language_service, vector_similarity_service, redis_storage_service)
    @language_service = language_service
    @vss = vector_similarity_service
    @redis = redis_storage_service
  end

  def generate_ai_response(**args)
    log_info("Starting AI processing")
  
    question_embedding = @language_service.get_embeddings(args[:content])   
    store_query_in_redis(question_embedding, args[:content])
    
    original = find_most_similar_text_and_text_id(question_embedding)
    ai_response = generate_ai_response_from_prompt(original_text: original[:text], content: args[:content], prompt: args[:prompt])
  
    log_info("Completed AI processing")
    
    { content: ai_response, original_text_id: original[:text_id] }
  end
  
  private
  
  def store_query_in_redis(question_embedding, content)
    log_info("Storing query in Redis for content #{content}")

    query_vector = { "text_id": "chat_entry_content", "text_vector": question_embedding, "content": content }
    @redis.set_query(query_vector)
  end

  def find_most_similar_text_and_text_id(question_embedding)
    log_info("Finding most similar text based on embedding")
    @vss.query_original_text(question_embedding)
  end
  
  def generate_ai_response_from_prompt(**args)
    prompt_wrapped = generate_prompt(**args)
    log_info("Generating AI response based on prompt for prompt: #{prompt_wrapped}")
    @language_service.generate_response(prompt_wrapped)   
      # 'заглушка на время тестов'
  end
  
  def generate_prompt(**args)
     <<~PROMPT
     #{args[:prompt]}

      [Content]
      #{args[:content]}

    PROMPT
  end
end
