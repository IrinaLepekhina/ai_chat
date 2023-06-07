# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'dotenv-rails'

gem 'rails', '~> 7.0.4'
gem 'sprockets-rails'
gem 'puma', '~> 5.0'
gem 'jsbundling-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'cssbundling-rails'
gem 'jbuilder'
gem 'bootsnap', require: false

gem 'bcrypt'
gem 'jwt'

# gem 'redcarpet', github: "vmg/redcarpet", branch: "master"
gem 'carrierwave' # uploader
gem 'simple_form'
gem 'haml'
gem 'haml-rails'

gem 'active_model_serializers'
gem 'kaminari'
gem 'rouge'
gem 'nokogiri'

gem 'redis'
gem 'openai'
gem 'ruby-openai'

# good gems:
# gem letter_opener
# gem email-spec

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'

  gem 'rails-controller-testing'
  gem 'shoulda-matchers'

  gem 'spring'
  gem 'spring-commands-cucumber'
  gem 'spring-commands-rspec'

  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'spring-watcher-listen'

  gem 'guard-rspec', require: false

  gem 'yard'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

group :production do
  # gem 'mysql2', '~> 0.5'
  gem 'pg'
end