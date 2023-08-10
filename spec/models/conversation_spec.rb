require 'rails_helper'

describe Conversation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:chat_entries).dependent(:destroy) }
    it { is_expected.to have_many(:ai_responses).dependent(:nullify) }
  end

  describe 'validations' do
    it {  is_expected.to validate_presence_of(:user).with_message("must exist") }
  end

  describe '#add_message' do
    let(:user) { create(:user) }
    let(:conversation) { create(:conversation, user: user) }

    it 'creates a new chat entry with the given content' do
      content = 'Hello, how are you?'
      expect(conversation.chat_entries.count).to eq(0)

      conversation.add_message(content)

      expect(conversation.chat_entries.count).to eq(1)
      expect(conversation.chat_entries.first.content).to eq(content)
    end
  end
end
