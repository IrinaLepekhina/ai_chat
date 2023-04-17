require 'rails_helper'

RSpec.describe Meal, type: :model do
  subject { build(:meal) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:price_type) }
  it { is_expected.to validate_presence_of(:price_init) }
  it { is_expected.to validate_numericality_of(:price_init).is_greater_than(0) }
end
