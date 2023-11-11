require 'rails_helper'

describe Prompt, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:ai_responses).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
  end
end
