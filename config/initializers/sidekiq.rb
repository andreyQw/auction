
Sidekiq.configure_server do |config|
  # config.redis = { url: 'redis://redis.example.com:7372/12' }
  config.redis = { url: 'redis://localhost:6379/sidekiq_test' }
end

Sidekiq.configure_client do |config|
  # config.redis = { url: 'redis://redis.example.com:7372/12' }
  config.redis = { url: 'redis://localhost:6379/sidekiq_test' }
end