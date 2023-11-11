require 'rails_helper'

describe Api::V1::ChatEntriesController, type: :request do
  describe 'POST /api/v1/chat_entries' do
    let(:user)                     { create(:user) }
    let(:conversation)             { create(:conversation, user: user) }
    let(:ai_integration_component) { instance_double('AiIntegrationComponent') }
    let!(:prompt)                  { create(:prompt) }

    let(:headers_json) { { "Accept" => "application/json" } }
    let(:headers_html) { { "Accept" => "text/html" } } 
  
    before :each do
      allow_any_instance_of(ApiController).to receive(:authorize_request).and_return(user)
    end

    before do 
      allow(AiIntegrationComponent).to receive(:new).and_return(ai_integration_component)
      allow(ai_integration_component).to receive(:generate_ai_response).and_return({content: 'Response', original_text_id: 'text id'})
    end

    context 'when requesting JSON format' do
      describe "POST create" do
        context 'valid data' do
          let(:valid_data) { attributes_for(:chat_entry) }
          before do
            post api_conversation_chat_entries_path(conversation.id), 
            params: { chat_entry: valid_data  }, 
            headers: headers_json, as: :json
          end
  
          it 'returns a JSON response with chat_entry' do
            expect(response).to have_http_status(:created)
            response_body = JSON.parse(response.body)
            expect(response_body['content']).to be_present
          end

          it 'creates a new chat entry' do
            expect(ChatEntry.count).to eq(1)
          end 
        end
    
        context 'invalid data' do
          let(:invalid_data) { attributes_for(:chat_entry, content: '') }

          before do
            post api_conversation_chat_entries_path(conversation.id), 
            params: { chat_entry: invalid_data  },  
            headers: headers_json, as: :json
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

    context 'when requesting HTML format' do
      describe "POST create" do
        context 'valid data' do
          let(:valid_data) { attributes_for(:chat_entry) }
          let(:valid_request) { post api_conversation_chat_entries_path(conversation.id), 
              params: { chat_entry: valid_data }, 
              headers: headers_html, as: :html 
            }

          it "creates new chat_entry in database" do
            expect do
              valid_request
            end.to change(ChatEntry, :count).by(1)
          end
           
          it 'redirects to conversation show' do
            valid_request
            expect(response).to redirect_to(api_conversation_path(assigns(:conversation)))
          end
        end

        context "invalid data" do
          let(:invalid_data) { attributes_for(:chat_entry, content: '') }
          let(:invalid_request) { post api_conversation_chat_entries_path(conversation.id), 
              params: { chat_entry: invalid_data }, 
              headers: headers_html, as: :html 
            } 
      
          it "redirects to conversation show" do
            invalid_request
            expect(response).to redirect_to(api_conversation_path(assigns(:conversation)))
          end

          it "displays an alert" do
            invalid_request
            expect(flash[:alert]).to be_present
          end

          it "doesn't create new chat_entry in database" do
            expect do
              invalid_request
            end.not_to change(ChatEntry, :count)
          end
        end
      end
    end
  end
end  