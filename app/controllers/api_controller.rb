# ApiController is a subclass of ApplicationController that provides a set of common functionalities for API controllers.

class ApiController < ApplicationController
  # to use the default application layout for API views.
  layout 'application'

  # to handle exceptions and HTTP responses, respectively
  include Exceptionable
  include Response
end
