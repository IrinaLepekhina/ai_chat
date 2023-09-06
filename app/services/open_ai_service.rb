# app/services/open_ai_service.rb

# The OpenAiService class interacts with the OpenAI API to generate AI responses and obtain text embeddings.
class OpenAiService
  include Loggable
  def initialize
    # Create a new instance of the OpenAI client using the provided API key
    @client = OpenAI::Client.new(access_token:  ENV['OPENAI_API_KEY'])
  end

  def generate_response(prompt)
    log_info("Generate an AI response using the OpenAI completions API")
    response = @client.completions(
      parameters: {
        model: "text-davinci-003",
        prompt: prompt,
        temperature: 0.2,
        max_tokens: 500
      }
    )

    process_open_ai_response_errors(response)
    log_info("Generated response successfully")

    # Extract the generated text from the API response and remove leading whitespace
    response['choices'][0]['text'].lstrip
  end

  def get_embeddings(content)
    log_info("Fetching embeddings for content using OpenAI API")
    
    response = @client.embeddings(parameters: { model: "text-embedding-ada-002", input: content })

    process_open_ai_response_errors(response)

    log_info("Embeddings fetched successfully")

    response['data'][0]['embedding']
  end

  private

  def process_open_ai_response_errors(response)
    error = response['error']

    if error
      error_type    = error['type']
      error_message = error['message']

      log_error("OpenAI API error encountered", type: error_type, message: error_message)
  
      raise(ExceptionHandler::LanguageServiceError, error_message)
    end
  end   
end