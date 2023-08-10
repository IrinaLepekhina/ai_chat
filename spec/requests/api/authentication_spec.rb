require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /signup' do
    context 'when the request format is HTML' do
      let(:user_attributes) { attributes_for(:user) }

      it 'creates a new user and sets the JWT token cookie' do
        post api_signup_path, params: { user: user_attributes  }, as: :html

        expect(response).to redirect_to(root_path)
        expect(response).to have_http_status('302')  
        expect(response.media_type).to eq('text/html')
 
        expect(response.headers['Set-Cookie']).to include('jwt=') # Check if 'jwt=' is present
        expect(response.headers['Set-Cookie']).not_to include('jwt=;') # Check if 'jwt=' is not followed by an empty value
        expect(flash[:notice]).to eq('Account created successfully')
      end 

      it 'creates a new user and change buttons' #do'
      #   post api_signup_path, params: { user: user_attributes  }, as: :html

      #   expect(response).to redirect_to(root_path)
        
      #   follow_redirect!    
      #   expect(response.body).to include(user_attributes[:nickname])
      #   expect(response.body).not_to include('Register')
      #   expect(response.body).not_to include('Login')
      # end 
   
      it 'does not create a new user and renders the signup form with errors' do
        post api_signup_path, params: { user: attributes_for(:user, email: nil) }, as: :html

        expect(response).to render_template(:new)
        expect(response.body).to include("be blank")
      end
    end  
      
    context 'when the request format is JSON' do
      it 'creates a new user and returns the JWT token' do
        post api_signup_path, params: { user: attributes_for(:user) }, as: :json

        expect(response).to have_http_status(:created)
        expect(response.media_type).to eq('application/json')
        expect(response.headers['Authorization']).to include('Bearer')
        expect(JSON.parse(response.body)['message']).to eq('Account created successfully')
      end

      it 'does not create a new user and returns an error message' do
        post api_signup_path, params: { user: attributes_for(:user, email: nil) }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)  
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)['error']).to be_truthy
        expect(response.headers['Authorization']).to be_falsy
      end 
    end 
  end
 
  describe 'POST /login' do
    context 'when the request format is HTML' do
      let(:user) { create(:user) }
      it 'signs in the user and sets the JWT token cookie' do
        post api_login_path, params: { auth_params: { email: user.email, password: user.password } }, as: :html
        expect(response).to redirect_to(root_path)
        expect(response.media_type).to eq('text/html')
        expect(flash[:notice]).to eq('You are logged in')
        
        expect(response.headers['Set-Cookie']).to include('jwt=')
        expect(response.headers['Set-Cookie']).not_to include('jwt=;')
      end
  
      it 'logs in the user and change buttons' #do
        # post api_login_path, params: { auth_params: { email: user.email, password: user.password } }, as: :html
        # expect(response).to redirect_to(root_path)

        # follow_redirect!
   
        # expect(response.body).not_to include('Register') 
        # expect(response.body).to include(user.nickname)
        # expect(response.body).not_to include('Login') 
      # end

      it 'does not sign in the user and renders the login form with errors' do
        post api_login_path, params: { auth_params: { email: 'invalid@example.com', password: 'password' } }, as: :html
  
        expect(response).to redirect_to(api_login_path)
        expect(flash[:alert]).to eq('Invalid credentials')
      end   
    end
     
    context 'when the request format is JSON' do
      let(:user) { create(:user) }   

      it 'signs in the user and returns the JWT token' do
        post api_login_path, params: { auth_params: { email: user.email, password: user.password } }, as: :json
        
        expect(response).to have_http_status(:success) 
        expect(response.media_type).to eq('application/json')
        expect(response.headers['Authorization']).to include('Bearer')
      end
  
      it 'does not sign in the user and returns an error message' do
        post api_login_path, params: { auth_params: { email: 'invalid@example.com', password: 'password' } }, as: :json
        
        expect(response).to have_http_status(:unauthorized)
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)['error']).to be_truthy
        expect(response.headers['Authorization']).to be_falsy
      end
    end
  end
end