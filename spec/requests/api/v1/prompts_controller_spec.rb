require 'rails_helper'

describe Api::V1::PromptsController, type: :request do
  let(:headers_html) { { "Accept" => "text/html" } }
  let(:user) { create(:user) }
  before do
    allow_any_instance_of(ApiController).to receive(:authorize_request).and_return(user)
  end

  describe 'POST create' do
    let(:prompt_params) { { prompt: { content: 'Sample prompt content' } } }

    it 'returns a :redirect HTML response and redirects to prompt#show' do
      post '/api/prompts', params: prompt_params, headers: headers_html, as: :html

      expect(response.content_type).to include("text/html")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(api_prompt_path(Prompt.last))
    end

    it 'creates a new prompt in the database' do
      expect {
        post '/api/prompts', params: prompt_params, headers: headers_html, as: :html
      }.to change(Prompt, :count).by(1)
    end
  end

  describe 'GET index' do
    let!(:prompt_list) { create_list(:prompt, 5) }

    before do 
      get api_prompts_path, headers: headers_html, as: :html
    end

    it 'renders :index template, with status 200' do
      expect(response).to render_template(:index)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/html")
    end

    it 'assigns prompts to template' do
      expect(assigns(:prompts)).to match_array(prompt_list)
    end
  end

  describe 'GET show' do
    let!(:prompt) { create(:prompt) }

    before do 
      get api_prompt_path(prompt), headers: headers_html, as: :html
    end

    it "renders :show template" do
      expect(response).to render_template(:show)
    end

    it "assigns requested prompt to @prompt" do
      expect(assigns(:prompt)).to eq(prompt)
    end
  end
end