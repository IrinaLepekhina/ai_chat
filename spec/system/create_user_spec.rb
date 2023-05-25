# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/new_user_form'


describe 'Creating a new user' do

  # to use the post method provided by Rails' ActionDispatch::IntegrationTest class
  include ActionDispatch::IntegrationTest::Behavior

  context "in HTML format" do
    let(:new_user_form) { NewUserForm.new }

    it 'create new user with valid date' do
      new_user_form.visit_page.fill_in_with(
        email: 'test@email'
      ).submit

      expect(page).to have_content('Account created successfully') 
      expect(User.last.email).to eq('test@email')
      expect(BCrypt::Password.new(User.last.password_digest) == 'very_secure').to be_truthy


      # expect(page).to have_content('@test_name')
      # expect(page).to have_button('Logout')
      # expect(page).not_to have_link('New User')
      # expect(page).not_to have_link('Login')

    end

    it 'cannot create new user with invalid date' do
      new_user_form.visit_page.submit
      expect(page).to have_content("can't be blank")
    end
  end

  context 'in JSON format' do

    let(:valid_user_params)   { attributes_for(:user) }
    let(:invalid_user_params) { attributes_for(:user, email: '') }

    it 'creates a new user with valid data' do
      post '/api/signup', params: { user: valid_user_params }, as: :json

      expect(response).to have_http_status(:created)
      expect(response.media_type).to eq('application/json')
      expect(response.headers['Authorization']).to include('Bearer')
      expect(JSON.parse(response.body)['message']).to eq('Account created successfully')
    end

    it 'returns an error for invalid data' do
      post '/api/signup', params: { user: invalid_user_params }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.media_type).to eq('application/json')
      expect(JSON.parse(response.body)['error']).not_to be_empty
    end
  end
end