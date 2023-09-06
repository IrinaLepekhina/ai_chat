# frozen_string_literal: true

# initial controller to test rspec + redis
module Api
  module V1
    class WelcomeController < ApiController
      skip_before_action :authorize_request

      def index
        redis = Redis.new(host: "#{ENV['REDIS_HOST']}", port: "#{ENV['REDIS_PORT']}".to_i)
        redis.incr "page hits"
        @page_hits = redis.get "page hits"
      end
    end
  end
end
