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
    log_info("Starting AI processing")

    question_embedding = 
    @language_service.get_embeddings(content)   
    #  JSON.parse(File.read('spec/fixtures/question_embedding.json')) 

    store_query_in_redis(question_embedding, content)
    
    original    = find_most_similar_text_and_text_id(question_embedding)
    ai_response = generate_ai_response_from_prompt(original[:text], content)

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
  
  def generate_ai_response_from_prompt(original_text, content)
    prompt = generate_prompt(original_text, content)
    log_info("Generating AI response based on prompt for prompt: #{prompt}")
    @language_service.generate_response(prompt)   
      # 'заглушка на время тестов'
  end
  
  def generate_prompt(original_text, content)
     <<~PROMPT
      Вы - чат-бот поддержки MUUL.ru, помогающий в выборе и заказе упаковки. 

      # Информация о компании будет предоставлена в разделе [Article]. 
      Вопрос клиента будет представлен в разделе [Content]. 
      Вы будете отвечать на вопросы клиента на основе информации из [Article]. 
      Если вопрос пользователя не находит ответа в [Article], вы ответите: "Прошу прощения, я не знаю, я передал вопрос менеджеру - менеджер ответит с 9 до 18 по Москве." И дайте ссылку на сайт  [https://muul.ru/].
            
      # [Article]
        MUUL.ru - индивидуальная упаковка от 30 до 1000 штук от производителя BOXSTORE
              
        Продукты:
        0427: Самосборная коробка. [https://muul.ru/korobka0427-zakaz]
        0201: Четырехклапанная. [https://muul.ru/korobka0201-zakaz]
        0215: Для высоких легких товаров. [https://muul.ru/korobka21-zakaz]
        0330: Коробка крышка-дно для подарков и хранения (предзаказ). [https://muul.ru/korobka0330-zakaz]
        
        Для расчета стоимости коробки предлагай выбрать на сайте: форму, размер (длина x ширина x высота в мм), цвет и количество, добавить в корзину и сделать заказ.
        
        Заказ на MUUL.ru:
        1. Оформление заказа: выбор параметров, расчет, выбор и оплата.
        2. Изготовление заказа до 7 рабочих дней после оплаты.
        3. Доставка через ТК СДЭК: до двери или ПВЗ. Трек-номер предоставляется в письме.
      
      # [Content]
      # #{content}


    PROMPT
  end
end
