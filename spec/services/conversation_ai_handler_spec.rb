require 'rails_helper'

describe ConversationAiHandler, type: :service do
  let(:redis)                   { instance_double('RedisStorageService') }
  let(:language_service)        { instance_double('EmbeddingsAdapter') }
  let(:vector_similarity_service) { instance_double('VectorSimilarityService') }
  let(:conversation_ai_handler) { ConversationAiHandler.new(language_service, vector_similarity_service, redis) }

  let(:content)             { 'list your terms of conditions?' }
  let(:question_embedding)  { JSON.parse(File.read('spec/fixtures/question_embedding.json')) }
  let(:original_text)       { 'text' } 
  let(:original)            { {text: original_text, text_id: 'terms_of_condition'} } 
  let(:ai_response_content) { "AI response" }
  let!(:prompt)             { create(:prompt) }

  describe "#generate_ai_response" do
    before do
      allow(language_service).to receive(:get_embeddings).with(content).and_return(question_embedding)
      allow(vector_similarity_service).to receive(:query_original_text).with(question_embedding).and_return(original)
      allow(redis).to receive(:set_query)
      allow(language_service).to receive(:generate_response).with('prompt_wrapped').and_return(ai_response_content)
      allow(conversation_ai_handler).to receive(:generate_prompt).with(original_text: original_text, content: content, prompt: prompt).and_return('prompt_wrapped')
    end

    it 'generates AI response based on content' do
      response = conversation_ai_handler.generate_ai_response(content: content, prompt: prompt)
      expect(response).to eq({ content: ai_response_content, original_text_id: original[:text_id] })
    end
  end
end
