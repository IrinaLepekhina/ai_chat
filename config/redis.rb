# config/redis.rb

# This configuration file sets up the Redis connection for the application.
# It creates a global `$redis` variable that can be used to interact with Redis.
# In this example, it connects to Redis running on the localhost with default port 6379.

$redis = Redis.new(host: 'localhost', port: 6379)
