require 'rails_helper'

# RSpec.describe 'Conversations API', type: :request do
#   # describe 'GET /api/conversations' do
#   #   let(:user) { create(:user) } 
#   #   let(:auth_token) {AuthenticateUser.new(user.email, user.password).call}
    
#   #   it 'returns all conversations' do
#   #     conversation_list = create_list(:conversation, 5, user: user) 
#   #     get api_conversations_path, 
#   #     params: { user_id: user.id }, 
#   #     headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" }, as: :json

#   #     expect(response).to have_http_status(:success) 
#   #     expect(JSON.parse(response.body)['conversations'].size).to eq(5)
#   #   end
#   # end

#   # describe 'GET /api/conversations/:id' do
#   #   let(:user) { create(:user) } 
#   #   let(:auth_token) {AuthenticateUser.new(user.email, user.password).call}
    
#   #   it 'returns a specific conversation' do
#   #     conversation = create(:conversation, user: user)
#   #     get "/api/conversations/#{conversation.id}", 
#   #       params: { user_id: user.id }, 
#   #       headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" }, as: :json

#   #     expect(response).to have_http_status(:success)
#   #     expect(JSON.parse(response.body)['conversation']['id']).to eq(conversation.id)
#   #   end
#   # end

#   describe 'POST /api/conversations' do
#     let!(:user) { create(:user) } 
#     let(:auth_token) {AuthenticateUser.new(user.email, user.password).call}
#     let(:ai_integration_component) { instance_double(AiIntegrationComponent) }
#     let(:valid_data) { attributes_for(:conversation) }

#     before do
#       allow(AiIntegrationComponent).to receive(:new).and_return(ai_integration_component)
#       allow(ai_integration_component).to receive(:generate_ai_response).and_return('Response') 
#     end

#     it 'creates a new conversation and generates a response' do
#       post '/api/conversations',
#         params: { user_id: user.id}, 
#         headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" }, as: :json

#       debugger
#       expect(response).to have_http_status(:success)
#       response_body = JSON.parse(response.body)
#       expect(response_body['response_ai']).to be_present
#       # expect(Conversation.count).to eq(1)       
#       # expect(ChatEntry.count).to eq(1)
#     end

#     it "creates a new conversation in database" do
#       expect do
#         post '/api/conversations',
#         params: { conversation: valid_data}, 
#         headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" }, as: :json
#       end.to change(Conversation, :count).by(1)
#     end
#   end
# end 

RSpec.describe 'Conversations API', type: :request do
  let(:user) { create(:user) }
  let(:auth_token) { AuthenticateUser.new(user.email, user.password).call }
  let(:ai_integration_component) { instance_double(AiIntegrationComponent) }
  # let(:nested_valid_data) { }
  # let(:invalid_chat_entry_data) { { title: "nested conversation", chat_entries_attributes: { "0" => { message: "" } } } }
  before do
    allow(AiIntegrationComponent).to receive(:new).and_return(ai_integration_component)
    allow(ai_integration_component).to receive(:generate_ai_response).and_return('Response') 
  end
  
  describe 'POST /api/conversations' do
    context 'valid data' do
      let(:valid_data) { attributes_for(:conversation, user_id: user.id) }
      let(:valid_nested_data) {
        {
          user_id: user.id,
          chat_entries_attributes: [
            {
              content: "nested conversation",
              user_id: user.id
            }
          ]}} 
      
      let(:headers) {
        {
          "Accept" => "application/json",
          "Authorization" => "Bearer #{auth_token}"
        }}
            
      let(:valid_request) { 
        post '/api/conversations', params: {conversation: valid_data}, 
        headers: headers,
        as: :json 
      }
      
      context 'without nested chat_entries' do
        it 'returns a success response' do
          valid_request
          expect(response).to have_http_status(:success)
        end

        it 'creates a new conversation in the database' do
          expect {
            valid_request
          }.to change(Conversation, :count).by(1)
        end  
      end

      context 'with nested chat_entries' do
        let(:valid_nested_data) {
          {
            user_id: user.id,
            chat_entries_attributes: [
              {
                content: "nested conversation"
              }
            ]}}

        let(:valid_nested_request) {
          post '/api/conversations',
            params: { conversation: valid_nested_data },
            headers: headers,
            as: :json
        }  

        it 'creates a new conversation and associated chat_entries in the database' do
          expect {
            valid_nested_request
          }.to change(Conversation, :count).by(1)
           .and change(ChatEntry, :count).by(1)
        end

        it 'returns a success response' do
          valid_nested_request
          expect(response).to have_http_status(:success)
        end
      end
    end

    # context 'invalid data' do
    #   context 'without nested chat_entries' do
    #     it 'does not create a new conversation in the database' do
    #       expect {
    #         post '/api/conversations',
    #              params: { conversation: invalid_conversation_data },
    #              headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" },
    #              as: :json
    #       }.not_to change(Conversation, :count)
    #     end

    #     it 'returns a validation error response' do
    #       post '/api/conversations',
    #            params: { conversation: invalid_conversation_data },
    #            headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" },
    #            as: :json

    #       expect(response).to have_http_status(:unprocessable_entity)
    #     end
    #   end

    #   context 'with invalid chat_entry' do
    #     it 'does not create a new conversation and chat_entry in the database' do
    #       expect {
    #         post '/api/conversations',
    #              params: { conversation: invalid_chat_entry_data },
    #              headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" },
    #              as: :json
    #       }.not_to change(Conversation, :count).and not_to change(ChatEntry, :count)
    #     end
    #     it 'returns a validation error response' do
    #       post '/api/conversations',
    #            params: { conversation: invalid_chat_entry_data },
    #            headers: { "Accept" => "application/json", "Authorization" => "Bearer #{auth_token}" },
    #            as: :json
    
    #       expect(response).to have_http_status(:unprocessable_entity)
    #     end
    #   end
    # end
  end
end