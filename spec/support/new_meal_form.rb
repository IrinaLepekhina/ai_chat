class NewMealForm
  include Capybara::DSL

  def visit_page
    visit('/')
    click_on('create new meal')
    self
  end

  def fill_in_with(_params = {})
    fill_in('Title', with: 'Okroshka')
    fill_in('Price', with: '134.5')
    fill_in('Description', with: 'Okroshka description')

    select('per unit', from: 'Price type') # by weight
    # select('Main dish', from: 'Category')
    self
  end

  def submit
    click_on('submit')
    self
  end
end
