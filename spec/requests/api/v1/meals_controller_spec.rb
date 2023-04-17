require 'rails_helper'

RSpec.describe Api::V1::MealsController do
  context "when requesting HTML format" do
    describe "GET index" do
      let!(:meal) { create(:per_unit_meal) }

      before do
        get '/api/meals', headers: { "Accept" => "text/html" }
      end

      it 'renders :index template, with status 200' do
        expect(response).to render_template(:index)
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("text/html; charset=utf-8")
      end

      it 'assigns meals to template' do
        expect(assigns(:meals)).to contain_exactly(meal)
      end
    end
  end

  context "when requesting JSON format" do
    describe "GET index" do
      it 'sends meals, with status 200' do
        by_weight_meal = create(:by_weight_meal, title: 'la ensalsda Mexicana')
        per_unit_meal = create(:per_unit_meal)

        get '/api/meals', params: {}, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json.count).to eq(2)
        expect(json[0]["title"]).to eq('la ensalsda Mexicana')
      end
    end
  end
end
