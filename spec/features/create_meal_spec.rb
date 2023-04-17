# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/new_meal_form'

describe 'Creating a new meal' do
  # to use the post method provided by Rails' ActionDispatch::IntegrationTest class
  include ActionDispatch::IntegrationTest::Behavior

  context "in HTML format" do
    let(:new_meal_form) { NewMealForm.new }

    it 'create new meal with valid date' do
      new_meal_form.visit_page.fill_in_with(
        title: 'Okroshka'
      ).submit

      expect(page).to have_http_status(:ok) # expect(page.status_code).to eq(200)
      expect(page.response_headers['Content-Type']).to include('text/html')
      expect(page).to have_content('Record created successfully')
      expect(Meal.last.title).to eq('Okroshka')
    end

    it 'cannot create new meal with invalid date' do
      new_meal_form.visit_page.submit

      expect(page).to have_http_status(:ok) # expect(page.status_code).to eq(200)
      expect(page.response_headers['Content-Type']).to include('text/html')
      expect(page).to have_content("can't be blank")
      expect(page).to have_current_path(api_meals_path)
    end
  end

  context "in JSON format" do
    context 'when submitting valid data' do
      let(:valid_data) { attributes_for(:by_weight_meal, title: 'Test Meal') }

      it 'create new meal with valid date' do
        post api_meals_path, params: { meal: valid_data }, as: :json

        expect(response).to have_http_status(:created)
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)['message']).to eq('Record created successfully')
        expect(JSON.parse(response.body)['meal']['title']).to eq('Test Meal') # expect(response.body).to include('Test Meal')
      end
    end

    context 'when submitting invalid data' do
      it 'displays error messages' do
        post api_meals_path, params: { meal: { title: '' } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity) # expect(response.status).to eq(422)
        expect(response.body).to have_content('error')
      end
    end
  end
end
