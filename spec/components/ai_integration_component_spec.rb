# spec/components/ai_integration_component_spec.rb

require 'rails_helper'

RSpec.describe AiIntegrationComponent do
  describe '#generate_ai_response' do
    # Create test doubles for the dependencies
    let(:openai_service) { instance_double('OpenAiService') }
    let(:cosine_similarity_service) { instance_double('CosineSimilarityService') }
    let(:conversation_ai_handler) { instance_double('ConversationAiHandler') }
    let(:conversation) { instance_double('Conversation') }
    let(:csv_storage_service) { instance_double('CsvStorageService') }
    let(:content) { 'Hello, how are you?' }

    subject { described_class.new } 

    before do
      # Stub the dependencies and their behavior
      allow(OpenAiService).to receive(:new).and_return(openai_service)
      allow(CosineSimilarityService).to receive(:new).and_return(cosine_similarity_service)
      allow(CsvStorageService).to receive(:new).and_return(csv_storage_service)
      allow(ConversationAiHandler).to receive(:new).and_return(conversation_ai_handler)
      allow(conversation_ai_handler).to receive(:generate_ai_response).and_return("Hi there! I'm doing great")
    end

    it 'delegates the generation of AI response to ConversationAiHandler' do
      # Expect the ConversationAiHandler to be initialized with the correct dependencies
      expect(ConversationAiHandler).to receive(:new).with(openai_service, cosine_similarity_service, csv_storage_service).and_return(conversation_ai_handler)

      # Expect the ConversationAiHandler to generate AI response for the given content
      expect(conversation_ai_handler).to receive(:generate_ai_response).with(content).and_return("Hi there! I'm doing great")

      # Call the method under test
      response = subject.generate_ai_response(conversation, content)

      # Verify the response contains the expected AI-generated message
      expect(response).to include("Hi there! I'm doing great")
    end
  end 
end
