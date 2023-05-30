require 'rails_helper'

RSpec.describe ConversationHandlingComponent do
  let(:ai_integration_component) { instance_double(AiIntegrationComponent) }
  subject { described_class.new(ai_integration_component) }
 
  describe '#process_chat_entry' do
    let(:conversation) { instance_double(Conversation) }
    let(:message) { 'Hello' }
    let(:response) { 'Hi there!' }

    it 'generates a response using AIIntegrationComponent' do
      expect(ai_integration_component).to receive(:generate_ai_response).with(conversation, message).and_return(response)
      expect(subject.process_chat_entry(conversation, message)).to eq(response)
    end
  end
end
