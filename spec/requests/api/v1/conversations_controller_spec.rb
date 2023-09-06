require 'rails_helper'

describe Api::V1::ConversationsController, type: :request do
  let(:user)         { create(:user) }
  let(:headers_json) { { "Accept" => "application/json" } }
  let(:headers_html) { { "Accept" => "text/html" } }

  before do
    allow_any_instance_of(ApiController).to receive(:authorize_request).and_return(user)
  end
 
  context "when requesting JSON format" do
    describe 'POST create' do
      let(:ai_integration_component) { instance_double('AiIntegrationComponent') }
  
      before do
        allow(AiIntegrationComponent).to receive(:new).and_return(ai_integration_component)
        allow(ai_integration_component).to receive(:generate_ai_response).and_return('hi')
        allow_any_instance_of(ApiController).to receive(:current_user).and_return(user)
      end

      before do
        post '/api/conversations', headers: headers_json, as: :json
      end

      it 'returns a success JSON response' do
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("application/json")
      end

      it 'returns the conversation_id' do
        expect(JSON.parse(response.body)).to include('user_id')
      end

      it 'creates a new conversation in the database' do
        expect {
          post '/api/conversations', headers: headers_json, as: :json
        }.to change(Conversation, :count).by(1)
      end

      it 'does not create a new chat_entry in the database' do
        expect {
          post '/api/conversations', headers: headers_json, as: :json
        }.not_to change(ChatEntry, :count)
      end

      context "when current_user is nil" do
        before do
          allow_any_instance_of(ApiController).to receive(:current_user).and_return(nil)
        end
    
        describe 'POST create' do
          before do
            post '/api/conversations', headers: headers_json, as: :json
          end
    
          it 'returns an unprocessable entity response' do
            # debugger
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to include("application/json")
          end
    
          it 'does not create a new conversation in the database' do
            expect {
              post '/api/conversations', headers: headers_json, as: :json
            }.not_to change(Conversation, :count)
          end
        end
      end
    end

    describe 'GET index' do
      it 'returns all conversations' do
        conversation_list = create_list(:conversation, 5, user: user) 
        get api_conversations_path, params: {}, headers: headers_json, as: :json
        expect(response).to have_http_status(:found)
        expect(JSON.parse(response.body).size).to eq(5)
      end
    end
  
    describe 'GET show' do
      it 'returns a specific conversation' do
        conversation = create(:conversation, user: user)
        get "/api/conversations/#{conversation.id}", headers: headers_json, as: :json
        expect(response).to have_http_status(:found)
        expect(JSON.parse(response.body)['id']).to eq(conversation.id)
      end
    end

    describe "DELETE destroy" do
      let!(:conversation) {create(:conversation, user: user)}

      it "sends notice" do
        delete "/api/conversations/#{conversation.id}", headers: headers_json, as: :json
        expect(response.body).to include('Conversation deleted') 
      end

      it "deletes conversation from database" do
        delete "/api/conversations/#{conversation.id}", headers: headers_json, as: :json
        expect(Conversation).not_to exist(conversation.id)
      end
    end
  end
 
  context 'when requesting HTML format' do
    describe 'POST create' do
      let(:ai_integration_component) { instance_double('AiIntegrationComponent') }
  
      before do
        allow(AiIntegrationComponent).to receive(:new).and_return(ai_integration_component)
        allow(ai_integration_component).to receive(:generate_ai_response).and_return('hi')
        allow_any_instance_of(ApiController).to receive(:current_user).and_return(user)
      end

      before do
        post '/api/conversations', headers: headers_html, as: :html
      end
    
      it 'returns a :redirect HTML response and redirects to conversation#show' do
        expect(response.content_type).to include("text/html")
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(api_conversation_path(Conversation.last))
      end

      it 'renders :show template' do
        follow_redirect!
        expect(response).to render_template(:show)
      end

      it 'creates a new conversation in the database' do
        expect {
          post '/api/conversations', headers: headers_html, as: :html
        }.to change(Conversation, :count).by(1)
      end

      it 'does not create a new chat_entry in the database' do
        expect {
          post '/api/conversations', headers: headers_html, as: :html
        }.not_to change(ChatEntry, :count)
      end
    end

    describe 'GET index' do
      let!(:conversation_list)  {create_list(:conversation, 5, user: user)}

      before :each do 
        get api_conversations_path, headers: headers_html, as: :html
      end

      it 'renders :index template, with status 200' do
        expect(response).to render_template(:index)
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("text/html; charset=utf-8")
      end
      
      it 'assigns conversations to template' do
        expect(assigns(:conversations)).to match_array(conversation_list)
      end
    end
  
    describe 'GET show' do
      let!(:conversation) {create(:conversation, user: user)}

      before do 
        get "/api/conversations/#{conversation.id}", headers: headers_html, as: :html
      end

      it "renders :show template" do
        expect(response).to render_template(:show)
      end

      it "assigns requested conversation to @conversation" do
        expect(assigns(:conversation)).to eq(conversation)
      end
    end

    describe "DELETE destroy" do
      let!(:conversation) {create(:conversation, user: user)}

      it "redirects to conversations#index" do
        delete "/api/conversations/#{conversation.id}", headers: headers_html, as: :html
        expect(response).to redirect_to(api_conversations_path) 
      end

      it "deletes conversation from database" do
        delete "/api/conversations/#{conversation.id}", headers: headers_html, as: :html
        expect(Conversation).not_to exist(conversation.id)
      end
    end
  end
end