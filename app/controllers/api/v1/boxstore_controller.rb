# app/controllers/api/v1/boxstore_controller.rb

module Api
  module V1
    class BoxstoreController < ApiController

      BASE_URL = 'https://file.diid.tech/boxstore/api/'.freeze

      def api_versions
        @api_versions = fetch_from_boxstore('api-versions/')
      end 

      def credentials
        @credentials = fetch_from_boxstore('credentials/')
      end

      private

      def fetch_from_boxstore(endpoint)
        api_key = ENV['BOXSTORE_API_KEY']
        url = BASE_URL + endpoint

        response = Faraday.get(url, { apiKey: api_key })

        JSON.parse(response.body)
      end
    end
  end
end
