# app/services/open_ai_service.rb

# The OpenAiService class interacts with the OpenAI API to generate AI responses and obtain text embeddings.
class OpenAiService
  def initialize
    # Create a new instance of the OpenAI client using the provided API key
    @client = OpenAI::Client.new(access_token:  ENV['OPENAI_API_KEY'])
  end

  def generate_response(prompt)
    # Generate an AI response using the OpenAI completions API
    response = @client.completions(
      parameters: {
        model: "text-davinci-003",
        prompt: prompt,
        temperature: 0.2,
        max_tokens: 500,
      }
    )

    # Extract the generated text from the API response and remove leading whitespace
    response['choices'][0]['text'].lstrip
  end

  def get_embeddings(content)
    # Obtain text embeddings using the OpenAI embeddings API
    response = @client.embeddings(parameters: { model: "text-embedding-ada-002", input: content })
    response['data'][0]['embedding']
  end
end
