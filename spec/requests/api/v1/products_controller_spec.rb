require 'rails_helper'

RSpec.describe Api::V1::ProductsController do
  
  context "when requesting HTML format" do
    
    describe "GET index" do
      before do
        @user = create(:user)
        @auth_token = AuthenticateUser.new(@user.email, @user.password).call.last
      end
      let!(:product) { create(:per_unit_product) }
      
      before do
        get '/api/products', headers: { "Accept" => "text/html", "Authorization" => @auth_token }
      end
      
      it 'renders :index template, with status 200' do
        expect(response).to render_template(:index)
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("text/html; charset=utf-8")
      end

      it 'assigns products to template' do
        expect(assigns(:products)).to contain_exactly(product)
      end
    end
  end

  context "when requesting JSON format" do
    describe "GET index" do

      before do
        @user = create(:user)
        @auth_token = AuthenticateUser.new(@user.email, @user.password).call.last
      end
      
      it 'sends products, with status 200' do
        by_weight_product = create(:by_weight_product, title: 'la ensalsda Mexicana')
        per_unit_product = create(:per_unit_product)

        get '/api/products', params: {}, headers: { "Accept" => "application/json", "Authorization" => @auth_token}
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json.count).to eq(2)
        expect(json[0]["product_title"]).to eq('la ensalsda Mexicana')
      end
    end
  end
end
