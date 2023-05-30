require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:chat_entries).dependent(:destroy) }
  end

  describe 'validations' do
    it {  is_expected.to validate_presence_of(:user).with_message("must exist") }
  end
end
