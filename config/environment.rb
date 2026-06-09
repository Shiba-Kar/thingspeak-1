# Load the rails application
require File.expand_path('../application', __FILE__)

Thingspeak::Application.configure do
	config.action_controller.perform_caching = true
	config.cache_store = :file_store, "#{Rails.root}/tmp/cache"

	config.action_mailer.delivery_method = ENV['SMTP_DELIVERY_METHOD'].present? ? ENV['SMTP_DELIVERY_METHOD'].to_sym : :smtp
	config.action_mailer.smtp_settings = {
		:enable_starttls_auto => ENV['SMTP_ENABLE_STARTTLS_AUTO'].present? ? (ENV['SMTP_ENABLE_STARTTLS_AUTO'] == 'true') : true,
		:address => ENV['SMTP_ADDRESS'] || 'smtp.gmail.com',
		:port => (ENV['SMTP_PORT'] || 587).to_i,
		:domain => ENV['SMTP_DOMAIN'] || '',
		:authentication => ENV['SMTP_AUTHENTICATION'].present? ? ENV['SMTP_AUTHENTICATION'].to_sym : :plain,
		:user_name => ENV['SMTP_USER_NAME'] || '',
		:password => ENV['SMTP_PASSWORD'] || ''
	}
end

# Initialize the rails application
Thingspeak::Application.initialize!
