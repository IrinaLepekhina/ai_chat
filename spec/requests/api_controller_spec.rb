# spec/controllers/api_controller_spec.rb

require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  let(:user) { create(:user) }

  describe "#authorize_request" do
    context "when token is valid" do
      before do
        token = JsonWebToken.encode({ user_id: user.id })
        request.headers.merge!({ 'Authorization' => "Bearer #{token}" })
      end

      it "sets the current user" do
        subject.send(:authorize_request)
        expect(subject.current_user).to eq(user)
      end
    end

    context "when token is invalid" do
      before do
        request.headers.merge!({ 'Authorization' => "Bearer INVALID_TOKEN" })
      end

      it "does not set the current user" do
        expect { subject.send(:authorize_request) }.to raise_error(ExceptionHandler::InvalidToken)
        expect(subject.current_user).to be_nil
      end
    end
  end
end
