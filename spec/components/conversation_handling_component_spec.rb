# spec/components/conversation_handling_component_spec.rb

require 'rails_helper'

RSpec.describe ConversationHandlingComponent do
  describe '#process_chat_entry' do
    # Create test doubles and variables for the test case
    let(:ai_integration_component) { instance_double('AiIntegrationComponent') }
    let(:conversation) { Conversation.new }
    let(:content) { 'What is your store name?' }
    let(:default_response) { "How can I help you?" }

    subject { described_class.new(ai_integration_component) }

    context 'when chat entry content is not empty' do
      it 'generates a response using the AI integration component' do
        # Expect the AI integration component to generate an AI response
        expect(ai_integration_component).to receive(:generate_ai_response)
          .with(conversation, content)
          .and_return('Planta_Tony')

        # Call the method under test
        response = subject.process_chat_entry(conversation, content)

        # Verify that the response is not the default response and contains the generated AI response
        expect(response).not_to eq(default_response)
        expect(response).to include("Planta_Tony")
      end
    end

    context 'when chat entry content is empty' do
      let(:content) { '' }

      it 'returns a default response' do
        # Call the method under test
        response = subject.process_chat_entry(conversation, content)

        # Verify that the response is the default response
        expect(response).to eq(default_response)
      end
    end
  end
end
