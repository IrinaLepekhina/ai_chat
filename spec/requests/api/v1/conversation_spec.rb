require 'rails_helper'

RSpec.describe 'Conversations API', type: :request do
  
  let(:user) { create(:user) } 
  let(:auth_token) {AuthenticateUser.new(user.email, user.password).call}
  let(:headers) {{ "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" }}
  
  describe 'GET /api/conversations' do
    
    it 'returns all conversations' do
      conversation_list = create_list(:conversation, 5, user: user) 
      get api_conversations_path, params: { user_id: user.id }, headers: headers

      expect(response).to have_http_status(:success) 
      expect(JSON.parse(response.body)['conversations'].size).to eq(5)
    end
  end

  describe 'GET /api/conversations/:id' do

    it 'returns a specific conversation' do
      conversation = create(:conversation, user: user)
      get "/api/conversations/#{conversation.id}", params: { user_id: user.id }, headers: headers

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['conversation']['id']).to eq(conversation.id)
    end
  end

  describe 'POST /api/conversations' do

    let(:ai_integration_component) { instance_double(AiIntegrationComponent) }
  
    before do 
      allow(AiIntegrationComponent).to receive(:new).and_return(ai_integration_component)
    end
    
    context 'valid data' do
      let(:default_response) {"How can I help you?"}
            
      context 'without nested chat_entries' do
        let(:valid_data) { attributes_for(:conversation, user_id: user.id) }
        let(:valid_request) { post '/api/conversations', params: {conversation: valid_data}, headers: headers, as: :json }

        before do 
          allow(ai_integration_component).to receive(:generate_ai_response).and_return(default_response) 
        end

        it 'returns a success response' do
          valid_request
          
          expect(response).to have_http_status(:success)

        end
        
        it 'returns a default message' do
          valid_request
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body)["response_ai"]).to eq(default_response)
        end

        it 'creates a new conversation in the database' do
          expect {
            valid_request
          }.to change(Conversation, :count).by(1)
        end 
        
        it 'does not create a new chat_entries in the database' do
          expect {
            valid_request
          }.not_to change(ChatEntry, :count)
        end
        
      end
      
      context 'with nested chat_entries' do

        let(:valid_nested_data) {
          { user_id: user.id,
            chat_entries_attributes: [
              { content: "nested water conversation" }]}}
 
        let(:valid_nested_request) {
          post '/api/conversations', params: { conversation: valid_nested_data }, headers: headers, as: :json }

        before do 
          allow(ai_integration_component).to receive(:generate_ai_response).and_return('NOT default') 
        end

        it 'returns a success response' do
          valid_nested_request
 
          expect(response).to have_http_status(:success)
        end

        it 'returns a not_default message' do
          valid_nested_request
          expect(JSON.parse(response.body)["response_ai"]).not_to eq(default_response)
        end

        it 'creates a new conversation and associated chat_entries in the database' do
          expect {
            valid_nested_request
          }.to change(Conversation, :count).by(1)
           .and change(ChatEntry, :count).by(1)
        end
      end
    end
  end
end  