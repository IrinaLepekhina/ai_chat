# spec/support/capybara.rb
# Register the Selenium Chrome driver for running tests in a container
Capybara.register_driver :selenium_chrome_in_container do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--disable-dev-shm-usage') # Disable /dev/shm usage for improved compatibility in containers
  options.add_argument('--no-sandbox') # Disable the sandbox for better compatibility in containers
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://selenium_chrome:4444/wd/hub", # URL of the remote Selenium Chrome container
    options: options
end

# Register the headless Selenium Chrome driver for running tests in a container
Capybara.register_driver :headless_selenium_chrome_in_container do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--disable-dev-shm-usage') # Disable /dev/shm usage for improved compatibility in containers
  options.add_argument('--no-sandbox') # Disable the sandbox for better compatibility in containers
  options.add_argument('--headless=new') # Run Chrome in headless mode

  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://selenium_chrome:4444/wd/hub", # URL of the remote Selenium Chrome container
    options: options
end