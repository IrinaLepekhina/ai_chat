class NewUserForm
  include Capybara::DSL

  def visit_page
    visit('/')
    click_on('Register')
    self
  end

  def fill_in_with(_params = {})
    fill_in('name', with: 'Name')
    fill_in('email', with: 'test@email')
    fill_in('nickname', with: 'testname')

    fill_in('password', with: 'very_secure')

    self
  end

  def submit
    click_on('Create User')
    self
  end
end
