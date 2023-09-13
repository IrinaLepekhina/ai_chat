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

  def generate_ai_response(content)
    log_info("Starting AI processing for content")

    question_embedding = 
    @language_service.get_embeddings(content)   
    #  JSON.parse(File.read('spec/fixtures/question_embedding.json')) 

    store_query_in_redis(question_embedding, content)
    
    original    = find_most_similar_text_and_text_id(question_embedding)
    ai_response = generate_ai_response_from_prompt(original[:text], content)

    log_info("Completed AI processing for content")
    
    { content: ai_response, original_text_id: original[:text_id] }
  end
  
  private
  
  def store_query_in_redis(question_embedding, content)
    log_info("Storing query in Redis")

    query_vector = { "text_id": "chat_entry_content", "text_vector": question_embedding, "content": content }
    @redis.set_query(query_vector)
  end

  def find_most_similar_text_and_text_id(question_embedding)
    log_info("Finding most similar text based on embedding")
    @vss.query_original_text(question_embedding)
  end
  
  def generate_ai_response_from_prompt(original_text, content)
    log_info("Generating AI response based on prompt")
    prompt = generate_prompt(original_text, content)
    @language_service.generate_response(prompt)   
      # 'заглушка на время тестов'
  end
  
  def generate_prompt(original_text, content)
     <<~PROMPT
      Вы — AI-ассистент по имени Планта. Вы работаете на компанию, у которой есть своё производство, расположенное в городе N.
      Вы будете отвечать на вопросы клиента и ваш ответ будет полезным и дружелюбным.
      
      Информация о компании будет предоставлена в разделе [Article]. Вопрос клиента будет представлен в разделе [Content]. Вы будете отвечать на вопросы клиента на основе информации из [Article]. Если вопрос пользователя не находит ответа в [Article], вы ответите: "Прошу прощения, я не знаю".
      
      [Article]
      #{original_text}
      
      [Content]
      #{content}
    PROMPT
  end
end
