require 'rails_helper'

RSpec.describe 'ChatEntries API', type: :request do
  describe 'POST /api/v1/chat_entries' do
    let(:user) { create(:user) }
    let(:auth_token) {AuthenticateUser.new(user.email, user.password).call}
    let(:conversation) { create(:conversation, user: user) }
    let(:content) { 'Hello, how are you?' }
    let(:ai_integration_component) { instance_double(AiIntegrationComponent) }
  
    before do 
      allow(AiIntegrationComponent).to receive(:new).and_return(ai_integration_component)
      allow(ai_integration_component).to receive(:generate_ai_response).and_return('Response') 
    end

    context 'valid data' do
      before do
        post api_conversation_chat_entries_path(conversation.id), 
        params: { content: content, conversation: conversation }, 
        headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" }, as: :json
      end
  
      it 'creates a new chat entry, generates a response, and returns a JSON response' do
        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['response']).to be_present
        expect(ChatEntry.count).to eq(1)
      end  
    end
 
    
    context 'invalid data' do
      before do
        post api_conversation_chat_entries_path(conversation.id), 
        params: { content: '', conversation: conversation },  
        headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" }, as: :json
      end

      it 'returns an error JSON response for invalid parameters' do
        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
        expect(ChatEntry.count).to eq(0)
      end
    end
  end
end 