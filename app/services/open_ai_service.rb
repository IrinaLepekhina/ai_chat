# app/services/open_ai_service.rb

# The OpenAiService class interacts with the OpenAI API to generate AI responses and obtain text embeddings.
class OpenAiService
  include Loggable
  def initialize
    # Create a new instance of the OpenAI client using the provided API key
    @client = OpenAI::Client.new(access_token:  ENV['OPENAI_API_KEY'])
  end

  def generate_response(prompt:, content:)
    log_info("Generate an AI response using the OpenAI completions API")
  
    api_parameters = {
      model:       ENV['OPENAI_MODEL']            || "gpt-3.5-turbo",
      temperature: ENV['OPENAI_TEMPERATURE'].to_f || 0.2,
      max_tokens:  ENV['OPENAI_MAX_TOKENS'].to_i  || 500,
      messages:    [{ role: "system", content: prompt }, 
                    { role: "user", content: content }]
    }
  
    response = @client.chat(parameters: api_parameters)
  
    process_open_ai_response_errors(response: response)

    log_info("Generated response successfully")
    log_info("OpenAI model parameters: #{api_parameters.to_json}")
  
    # Extract the generated text from the API response
    response['choices'][0]['message']['content'].lstrip
  end

  def get_embeddings(content:)
    log_info("Fetching embeddings for content using OpenAI API")
  
    model = ENV['EMB_MODEL'] || 'text-embedding-ada-002'
    
    response = @client.embeddings(parameters: { model: model, input: content })
  
    process_open_ai_response_errors(response: response)
  
    log_info("Embeddings fetched successfully, used open_ai model: #{model}")

    response['data'][0]['embedding']
  end

  private

  def process_open_ai_response_errors(response:)
    error = response['error']
  
    if error
      error_type    = error['type']
      error_message = error['message']
  
      log_error("OpenAI API error encountered", type: error_type, message: error_message)
  
      raise(ExceptionHandler::LanguageServiceError, error_message)
    end
  end
end