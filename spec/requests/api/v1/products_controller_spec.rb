require 'rails_helper'

describe Api::V1::ProductsController do
  let(:user) { create(:user) }
  let(:headers_json) { { "Accept" => "application/json" } }
  let(:headers_html) { { "Accept" => "text/html" } }

  before do
    allow_any_instance_of(ApiController).to receive(:authorize_request).and_return(user)
  end
  
  context "when requesting HTML format" do
    describe "GET index" do
      let!(:product) { create(:per_unit_product) }
      
      before do
        get '/api/products', headers: headers_html
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
      it 'sends products, with status 200' do
        by_weight_product = create(:by_weight_product, title: 'la ensalsda Mexicana')
        per_unit_product = create(:per_unit_product)

        get '/api/products', params: {}, headers: headers_json
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json.count).to eq(2)
        expect(json[0]["product_title"]).to eq('la ensalsda Mexicana')
      end
    end
  end
end