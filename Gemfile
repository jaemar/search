source 'https://rubygems.org'

gem 'rails', '~> 8.0.2'
gem 'sqlite3', '>= 2.1'
gem 'puma', '>= 5.0'
gem 'jbuilder'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
# gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

gem 'elasticsearch', '~> 9.0.3'

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug', platforms: %i[ mri windows ], require: 'debug/prelude'
  gem 'rubocop-rails-omakase', require: false
  gem 'rspec-rails'
end
