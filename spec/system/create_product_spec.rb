# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/new_product_form'
require_relative '../support/login_form'

describe 'Creating a new product' do

  # to use the post method provided by Rails' ActionDispatch::IntegrationTest class
  include ActionDispatch::IntegrationTest::Behavior

  context "in HTML format" do

    let(:new_product_form) { NewProductForm.new }
    let(:login_form) { LoginForm.new }
    let(:user) { create(:user) }

    before do
      login_form.visit_page.login_as(user)
    end

    it 'create new product with valid date' do
      new_product_form.visit_page.fill_in_with(
        title: 'Okroshka'
      ).submit

      expect(page).to have_http_status(:ok) # expect(page.status_code).to eq(200)
      expect(page.response_headers['Content-Type']).to include('text/html')
      expect(page).to have_content('Record created successfully')
      expect(Product.last.title).to eq('Okroshka')
    end

    it 'cannot create new product with invalid date' do
      new_product_form.visit_page.submit

      expect(page).to have_http_status(:ok) # expect(page.status_code).to eq(200)
      expect(page.response_headers['Content-Type']).to include('text/html')
      expect(page).to have_content("can't be blank")
      expect(page).to have_current_path(api_products_path)
    end
  end

  context "in JSON format" do
    before do
      @user = create(:user)
      @auth_token = AuthenticateUser.new(@user.email, @user.password).call
    end

    context 'when submitting valid data' do
      let(:valid_data) { attributes_for(:by_weight_product, title: 'Test Product') }

      it 'create new product with valid date' do
        post api_products_path, params: { product: valid_data }, headers: { "Accept" => "application/json", "Authorization" => "Bearer #{@auth_token}" }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)['message']).to eq('Record created successfully')
        expect(JSON.parse(response.body)['product']['title']).to eq('Test Product') # expect(response.body).to include('Test Product')
      end
    end

    context 'when submitting invalid data' do
      let(:invalid_data) { attributes_for(:by_weight_product, title: '') }
      it 'displays error messages' do
        post api_products_path, params: { product: invalid_data }, headers: { "Accept" => "application/json", "Authorization" => "Bearer #{@auth_token}" }, as: :json

        expect(response).to have_http_status(:unprocessable_entity) # expect(response.status).to eq(422)
        expect(response.body).to have_content('error')
      end
    end
  end
end
