require 'rails_helper'

describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:conversations) }
  end
  
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_presence_of(:nickname) }
    it { is_expected.to validate_uniqueness_of(:nickname) }
    it { is_expected.to validate_exclusion_of(:nickname).in_array(%w(admin administrator)).with_message("is reserved") }

    context 'nickname format validation' do
      it 'allows valid nicknames' do
        valid_nickname = "valid_nickname123"
        user = build(:user, nickname: valid_nickname)
        expect(user).to be_valid
      end

      it 'does not allow invalid nicknames' do
        invalid_nickname = "invalid-nickname!"
        user = build(:user, nickname: invalid_nickname)
        expect(user).not_to be_valid
        expect(user.errors[:nickname]).to include("only allows letters, numbers, and underscores")
      end
    end
  end

  describe '#has_secure_password' do
    let(:user) { build(:user, password: nil, password_confirmation: nil) }
    
    it 'is invalid without a password' do
      expect(user.valid?).to be_falsey
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'is valid with a matching password and password_confirmation' do
      user.password = "password123"
      user.password_confirmation = "password123"
      expect(user.valid?).to be_truthy
    end

    it 'is invalid with a non-matching password and password_confirmation' do
      user.password = "password123"
      user.password_confirmation = "password321"
      expect(user.valid?).to be_falsey
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end
end
