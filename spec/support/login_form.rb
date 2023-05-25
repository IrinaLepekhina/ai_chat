class LoginForm
  include Capybara::DSL

  def visit_page
    visit('/')
    click_on('Login')
    self
  end

  def login_as(user)
    fill_in('email', with: user.email)
    fill_in('password', with: user.password)

    click_on('GO')
    self
  end
end
