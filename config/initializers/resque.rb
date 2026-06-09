# Configure Resque to use the REDIS_URL from the environment if present
if ENV['REDIS_URL'].present?
  Resque.redis = ENV['REDIS_URL']
end
