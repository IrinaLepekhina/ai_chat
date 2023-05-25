# frozen_string_literal: true
# spec/system/home_page_spec.rb

require 'rails_helper'

describe 'home page' do

  it "is enhanced with JavaScript on", js: true do
    visit('/')
    expect(page).to have_text("ENHANCED!")
  end

  it 'welcome message' do
    visit('/')
    expect(page).to have_content('Planta')
  end

  it "shows the number of page views" do
    visit('/')
    expect(page.text).to match('This page has been viewed')
  end
end
 