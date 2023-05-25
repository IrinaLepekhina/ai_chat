class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  # check whether version is specified or is default
  def matches?(request)
    check_headers(request.headers) || @default
  end

  private

  def check_headers(headers)
    # check version from Accept headers; expect custom media type `project_tracker`
    accept = headers[:accept]
    accept && accept.include?("application/vnd.menu_app_m.v#{@version}+json")
  end
end