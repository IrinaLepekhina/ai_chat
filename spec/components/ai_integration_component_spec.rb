require 'rails_helper'

describe AiIntegrationComponent do
  describe '#generate_ai_response' do

    let(:vector_similarity_service) { instance_double('VectorSimilarityService') }
    let(:language_service)          { instance_double('EmbeddingsAdapter') }
    let(:redis_storage_service)     { instance_double('RedisStorageService') }
    let(:conversation)              { instance_double('Conversation') }
    let(:conversation_ai_handler)   { instance_double('ConversationAiHandler') }
    let(:content)                   { "Hello, how are you?" }
    let(:ai_response_content)       { "Hi there! I'm doing great" } 
    let!(:prompt)                   { create(:prompt) }

    subject { AiIntegrationComponent.new } 

    before do
      allow(EmbeddingsAdapter).to receive(:new).and_return(language_service)
      allow(RedisStorageService).to receive(:new).and_return(redis_storage_service)
      allow(VectorSimilarityService).to receive(:new).and_return(vector_similarity_service)
    end

    it 'delegates the generation of AI response to ConversationAiHandler' do
      expect(ConversationAiHandler).to receive(:new)
        .with(language_service, vector_similarity_service, redis_storage_service)
        .and_return(conversation_ai_handler)

      expect(conversation_ai_handler)
        .to receive(:generate_ai_response)
        .with(conversation: conversation, content: content, prompt: prompt)
        .and_return(ai_response_content)

      response = subject.generate_ai_response(conversation: conversation, content: content, prompt: prompt)

      expect(response).to include("Hi there! I'm doing great") 
    end

    context 'when AI response generation fails' do
      it 'returns an error message in the AI response' do
        expect(ConversationAiHandler).to receive(:new)
          .with(language_service, vector_similarity_service, redis_storage_service)
          .and_return(conversation_ai_handler)
    
        expect(conversation_ai_handler)
          .to receive(:generate_ai_response)
          .with(conversation: conversation, content: content, prompt: prompt)
          .and_raise(ExceptionHandler::LanguageServiceError, 'LanguageServiceError')
    
        expect {
          subject.generate_ai_response(conversation: conversation, content: content, prompt: prompt)
        }.to raise_error(ExceptionHandler::LanguageServiceError, 'LanguageServiceError')
      end
    end
  end 
end