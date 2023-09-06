# spec/requests/api/v1/boxstore_controller_spec.rb
require 'rails_helper'

describe Api::V1::BoxstoreController, type: :request do
  let(:api_key) { '430zun8dr1u7htnv0zfuwv9molybwy' }
  let(:user) { create(:user) }

  before :each do
    allow_any_instance_of(ApiController).to receive(:authorize_request).and_return(user)
    allow(ENV).to receive(:[]).and_call_original # This line allows any other key access
    allow(ENV).to receive(:[]).with('BOXSTORE_API_KEY').and_return(api_key)
  end
  
  describe 'GET /api/boxstore/api_versions' do
    context 'when the request is successful' do
      it "displays API versions" do
        get '/api/boxstore/api_versions'
    
        expect(response.body).to include('<h1>API Versions</h1>')
        expect(response.body).to include('<li>1</li>') 
      end
    end

    context 'when the API request fails' do
      before do
        allow(ENV).to receive(:[]).with('BOXSTORE_API_KEY').and_return('wrong_key')
      end
    
      it "displays error message" do
        get '/api/boxstore/api_versions'
    
        expect(response.body).to include("Error: You don&#39;t have permissions")
        # You can add more specific expectations here if you know what the error message should look like
      end
    end
  end

  describe 'GET /api/boxstore/credentials' do
    context 'when the request is successful' do
      it "displays API credentials" do
        get '/api/boxstore/credentials'
        
        expect(response.body).to include("<h1>API Credentials</h1>")
        expect(response.body).to include("<li>api/api-versions</li>")
        # Add more expectations as needed
      end
    end

    context 'when the credentials request fails' do
      before do
        allow(ENV).to receive(:[]).with('BOXSTORE_API_KEY').and_return('wrong_key')
      end

      it "displays error message" do
        allow(ENV).to receive(:[]).with('BOXSTORE_API_KEY').and_return('wrong_key')
        get '/api/boxstore/credentials'
      
        expect(response.body).to include("Error: You don&#39;t have permissions")
      end
    end
  end
end
