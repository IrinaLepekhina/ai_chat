# spec/services/openai_service_spec.rb
require 'rails_helper'

RSpec.describe OpenAiService do
  let(:api_key) { ENV['OPENAI_API_KEY'] }
  let(:openai_service) { described_class.new }   

  describe '#get_embeddings' do
    it 'returns the embeddings for the given question' do
      content = 'Where is your company from?'
      embeddings = [0.1, 0.2, 0.3]

      allow_any_instance_of(OpenAI::Client).to receive(:embeddings).and_return(
        { 'data' => [{ 'embedding' => embeddings }] }
      )

      expect(openai_service.get_embeddings(content)).to eq(embeddings)
    end 
  end

  describe '#generate_response' do
    it 'generates a response based on the given prompt' do
      prompt = 'You are an AI assistant. Ask me a question.'
      response_text = 'What can you do for me?'

      allow_any_instance_of(OpenAI::Client).to receive(:completions).and_return( 
        { 'choices' => [{ 'text' => response_text, 'finish_reason' => 'stop' }] }
      )
 
      expect(openai_service.generate_response(prompt)).to eq(response_text)
    end
  end
end