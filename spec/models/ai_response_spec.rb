require 'rails_helper'

describe AiResponse, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:chat_entry) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:conversation).with_message("must exist") }
    it { is_expected.to validate_presence_of(:content).with_message("can't be blank") }
  end

  describe '#user' do
    let(:user) { create(:user) }
    let(:conversation) { create(:conversation, user: user) }
    let(:chat_entry) { create(:chat_entry, conversation: conversation) }

    it 'returns the user of the associated conversation' do
      expect(chat_entry.user).to eq(conversation.user)
    end
  end
end