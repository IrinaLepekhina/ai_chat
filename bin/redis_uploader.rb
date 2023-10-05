#!/usr/bin/env ruby
# bin/redis_uploader.rb

require_relative "../config/environment"

begin
  redis_service = RedisStorageService.new( 
    language_service: EmbeddingsAdapter.new(OpenAiService.new),
    redis_client:     Redis.new(host: "#{ENV['REDIS_HOST_WEB']}", port: "#{ENV['REDIS_PORT_WEB']}".to_i)
  )
  redis_service.vectorize_texts
  redis_service.load_db
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
