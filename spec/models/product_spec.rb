require 'rails_helper'

describe Product, type: :model do
  subject { build(:product) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:price_type) }
  it { is_expected.to validate_presence_of(:price_init) }
  it { is_expected.to validate_uniqueness_of(:title).with_message("has already been taken") }
  it { is_expected.to validate_numericality_of(:price_init).is_greater_than(0) }
end
