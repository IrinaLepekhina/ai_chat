# spec/services/openai_service_spec.rb

require 'rails_helper'

describe OpenAiService, type: :service do
  let(:openai_service) { described_class.new }

  context 'in isolation' do
    describe '#get_embeddings' do
      it 'returns the embeddings for the given question' do
        content = 'Where is your company from?'
        embeddings = [0.1, 0.2, 0.3]

        allow_any_instance_of(OpenAI::Client).to receive(:embeddings).with(parameters: hash_including(input: content)).and_return(
          { 'data' => [{ 'embedding' => embeddings }] }
        )
        
        expect(openai_service.get_embeddings(content: content)).to eq(embeddings)
      end    
    end

    describe '#generate_response' do
      it 'generates a response based on the given prompt and content' do
        prompt = 'You are an AI assistant. Ask me a question.'
        content = 'This is additional content for the AI.'
        response_text = 'What can you do for me?'

        allow_any_instance_of(OpenAI::Client).to receive(:chat).with(parameters: hash_including(messages: [{ role: "system", content: prompt }, { role: "user", content: content }])).and_return(
          { 'choices' => [{ 'message' => {'content' => response_text} }] }
        )

        expect(openai_service.generate_response(prompt: prompt, content: content)).to eq(response_text)
      end
    end
  end
end