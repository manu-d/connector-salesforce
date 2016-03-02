[ ![Codeship Status for maestrano/connector-salesforce](https://codeship.com/projects/e6e21510-b64b-0133-12fb-7a4b33b8d70b/status?branch=master)](https://codeship.com/projects/134339)

# SalesForce Connector

The aim of this connector is to implement data sharing between Connec! and SalesForce

### Configuration
Configure your SalesForce application. To create a new SalesForce application: http://geekymartian.com/articles/ruby-on-rails-4-salesforce-oauth-implementation/

Create a configuration file `config/application.yml` with the following settigns (complete with your SalesForce / Connec! credentials)
```
connec_api_id: 
connec_api_key: 
salesforce_client_id: 
salesforce_client_secret: 
```

### Run the connector locally against the Maestrano production environment
In the initialize `config/initializers/maestrano.rb`
```
config.app.host = 'http://localhost:3001'
```

### Run the connector
#### First time setup
```
# Install JRuby and gems the first time
rvm install jruby-9.0.5.0
gem install bundler
bundle
gem install foreman
```

#### Start the application
```
export PORT=8080
export RACK_ENV=development
foreman start
```
