source 'https://rubygems.org'
ruby '2.3.1', :engine => 'jruby', :engine_version => '9.1.5.0'

gem 'rails', '~> 4.2'
gem 'puma', require: false

gem 'figaro'
gem 'uglifier', '>= 1.3.0'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'maestrano-connector-rails', '~> 1.5'
gem 'config'
gem 'attr_encrypted', '~> 1.4.0'

gem 'restforce'
gem 'omniauth-salesforce'

gem 'turbolinks', '~> 2.5'
gem 'jquery-rails'
gem 'haml-rails'
gem 'bootstrap-sass'
gem 'autoprefixer-rails'

# Background jobs
gem 'sinatra', :require => false
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'slim'

# Redis caching
gem 'redis-rails'

group :production, :uat do
  gem 'rails_12factor'
  gem 'activerecord-jdbcpostgresql-adapter', :platforms => :jruby
  gem 'pg', :platforms => :ruby
end

group :test, :develpment do
  gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
  gem 'sqlite3', :platforms => :ruby
end

group :test do
  gem 'simplecov'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'timecop'
end
