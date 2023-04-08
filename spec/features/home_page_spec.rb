# frozen_string_literal: true

require 'rails_helper'

describe 'home page' do
  it 'welcome message' do
    visit('/')
    expect(page).to have_content('Lets eat')
  end
end
