# spec/components/dialog_component_spec.rb

require 'rails_helper'

describe DialogComponent do
  describe "#process_chat_entry" do
    let(:user)                     { create(:user) }
    let(:conversation)             { create(:conversation, user: user) }
    let(:chat_entry)               { create(:chat_entry, conversation: conversation) }
    let(:ai_integration_component) { instance_double('AiIntegrationComponent') }

    subject { described_class.new }

    before do
      allow(AiIntegrationComponent).to receive(:new).and_return(ai_integration_component)
      allow(ai_integration_component).to receive(:generate_ai_response).with(conversation, chat_entry.content).and_return({ content: "AI response content", original_text_id: 123 })
    end

    it 'generates and stores AI response in the database' do
      expect {
        subject.process_chat_entry(conversation, chat_entry)
      }.to change(AiResponse, :count).by(1)
      
      expect(AiIntegrationComponent).to have_received(:new).once
      expect(ai_integration_component).to have_received(:generate_ai_response).with(conversation, chat_entry.content).once
    end

    it 'updates the chat entry with the AI response' do
      expect {
        subject.process_chat_entry(conversation, chat_entry)
      }.to change { chat_entry.reload.ai_response_id }.from(nil).to(Integer)
    end
  end
end