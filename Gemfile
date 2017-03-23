source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'jquery-rails'
gem 'coffee-rails'
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'autoprefixer-rails'

gem 'puma', require: false
gem 'figaro'
gem 'uglifier', '>= 1.3.0'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'maestrano-connector-rails', '2.0.2.pre.RC9'

gem 'config'
gem 'attr_encrypted', '~> 1.4.0'

gem 'restforce'
gem 'omniauth-salesforce'
gem 'money'

# Background jobs
gem 'sinatra', require: false
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'slim'

# Redis caching
gem 'redis-rails'

group :production, :uat do
  gem 'activerecord-jdbcmysql-adapter', platforms: :jruby
  gem 'mysql2', platforms: :ruby
  gem 'rails_12factor'
end

group :test, :develpment do
  gem 'activerecord-jdbcsqlite3-adapter', platforms: :jruby
  gem 'sqlite3', platforms: :ruby
end

group :test do
  gem 'simplecov'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'timecop'
  gem 'webmock'
end
