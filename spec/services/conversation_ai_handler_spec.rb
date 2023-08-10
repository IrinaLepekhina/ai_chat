# spec/services/conversation_ai_handler_spec.rb

require 'rails_helper'

describe ConversationAiHandler, type: :service do
  let(:redis)                   { instance_double('RedisStorageService') }
  let(:language_service)        { instance_double('EmbeddingsAdapter') }
  let(:vss)                     { instance_double('VectorSimularityService') }
  let(:conversation_ai_handler) { ConversationAiHandler.new(language_service, vss, redis) }
  

  let(:content)             { 'list your terms of conditions?' }
  let(:question_embedding)  { JSON.parse(File.read('spec/fixtures/question_embedding.json')) }
  let(:query_vector)        { JSON.parse(File.read('spec/fixtures/chat_entry.json'), symbolize_names: true) }
  let(:original_text)       { 'By using our products, you agree to this, and we are obliged to comply with that.' } 
  let(:original)            { {text: original_text, text_id: 'terms_of_condition'} } 
  let(:ai_response_content) { "AI response" }
  let(:ai_response)         { {content: ai_response_content, original_text_id: "terms_of_condition"} }

  describe "#generate_ai_response" do
    let(:prompt) do
      <<~PROMPT
        You are an AI assistant. You work for Planta_Tony which is a water store located in Guadalajara.
        You will be asked questions from a customer and will answer in a helpful and friendly manner.

        You will be provided company information from Planta_Tony under the [Article] section. The customer question
        will be provided under the [Content] section. You will answer the customer's questions based on the article.
        If the user's question is not answered by the article, you will respond with "I'm sorry, I don't know."

        [Article]
        #{original_text}

        [Content]
        #{content}
      PROMPT
    end

    before do
      allow(language_service).to receive(:get_embeddings).with(content).and_return(question_embedding)
      allow(redis).to receive(:set_query).with(query_vector)
      allow(vss).to receive(:query_original_text).with(question_embedding).and_return(original)
      allow(language_service).to receive(:generate_response).with(prompt).and_return(ai_response_content)
      allow(conversation_ai_handler).to receive(:generate_prompt).with(original_text, content).and_return(prompt)
    end

    it 'generates AI response based on content' do
      response = conversation_ai_handler.generate_ai_response(content)
      expect(response).to eq(ai_response)
    end

    it 'gets embeddings for the content' do
      expect(language_service).to receive(:get_embeddings).with(content)
      conversation_ai_handler.generate_ai_response(content)
    end

    it 'queries original text based on question embedding' do
      expect(vss).to receive(:query_original_text).with(question_embedding)
      conversation_ai_handler.generate_ai_response(content)
    end

    it 'generates prompt based on original text and content' do
      expect(conversation_ai_handler).to receive(:generate_prompt).with(original_text, content)
      conversation_ai_handler.generate_ai_response(content)
    end

    it 'generates AI response based on the prompt' do
      expect(language_service).to receive(:generate_response).with(prompt)
      conversation_ai_handler.generate_ai_response(content)
    end
  end
end