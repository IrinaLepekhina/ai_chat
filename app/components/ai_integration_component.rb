# app/components/ai_integration_component.rb
class AiIntegrationComponent

  def generate_ai_response(similarity_text, content) 
    prompt = "You are an AI assistant. You work for Sterling Parts which is a car parts online store located in Australia.
              You will be asked questions from a customer and will answer in a helpful and friendly manner.
              
              You will be provided company information from Sterling Parts under the [Article] section. The customer question
              will be provided under the [Question] section. You will answer the customer's questions based on the article.
              If the user's question is not answered by the article, you will respond with 'I'm sorry, I don't know.'
              
              [Article]
              #{similarity_text}
              
              [Question]
              #{question}"

    ai_response = OpenAIService.generate_ai_response(prompt)
  
    ai_response

  end
end