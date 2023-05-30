# spec/components/conversation_handling_spec.rb

require 'rails_helper'

RSpec.describe ConversationHandlingComponent do
  describe '#process_chat_entry' do
    let(:user) { create(:user) }
    let(:conversation) { create(:conversation, user_id: user.id) }
    let(:content) { 'What are your store hours?' }
    let(:ai_integration) { instance_double(AiIntegrationComponent) }
    let(:conversation_handler) { ConversationHandlingComponent.new(ai_integration) }

    it 'generates an appropriate response based on user input and AI capabilities' do
      allow(ai_integration).to receive(:generate_ai_response).with(conversation, content).and_return('AI response')
      # def generate_ai_response(similarity_text, content) 

      response = conversation_handler.process_chat_entry(conversation, content)
      expect(response).to eq('AI response')
      expect(ai_integration).to have_received(:generate_ai_response).with(conversation, content)
    end
    
  end
end
