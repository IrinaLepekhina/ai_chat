# app/services/boxstore_service.rb

class BoxstoreService
  include Loggable
  
  BASE_URL = 'https://file.diid.tech/boxstore/api/'.freeze

  def initialize
    @api_key = ENV['BOXSTORE_API_KEY']
  end

  def api_versions
    fetch_from_boxstore('api-versions/')
  end

  def credentials
    fetch_from_boxstore('credentials/')
  end

  private

  def fetch_from_boxstore(endpoint)
    url = BASE_URL + endpoint
    log_info("Making request to Boxstore", url: url)

    response = Faraday.get(url, { apiKey: @api_key })

    unless response.status == 200
      log_error("Unexpected response from Boxstore", status: response.status, body: response.body)
      return nil # or raise an error based on your use case
    end

    JSON.parse(response.body)
  end
end
