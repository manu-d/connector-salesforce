[ ![Codeship Status for maestrano/connector-salesforce](https://codeship.com/projects/e6e21510-b64b-0133-12fb-7a4b33b8d70b/status?branch=master)](https://codeship.com/projects/134339)

# SalesForce Connector

The aim of this connector is to implement data sharing between Connec! and SalesForce

### Configuration
Configure your SalesForce application. To create a new SalesForce application: http://geekymartian.com/articles/ruby-on-rails-4-salesforce-oauth-implementation/

### Access Maestrano Developer Platform and create a sandbox application

:soon: :construction:


Edit the configuration file `config/application-sample.yml` with the correct credentials (both Salesforce's and Maestrano's Developer Platform ones).
```
encryption_key1: ''
encryption_key2: ''

salesforce_client_id: 'your_salesforce_id'
salesforce_client_secret: 'your_salesforce_secret'

REDIS_URL: redis://localhost:6379/0/connector-salesforce

MNO_DEVPL_HOST: https://dev-platform.maestrano.io
MNO_DEVPL_API_PATH: /api/config/v1/marketplaces
MNO_DEVPL_ENV_NAME: salesforce-uat
MNO_DEVPL_ENV_KEY: 'your_local_env_key'
MNO_DEVPL_ENV_SECRET: 'your_local_env_secret'

```

### Run the connector locally against the Maestrano UAT environment

### Run the connector
#### First time setup
```
# Install bundler and update your gemset
gem install ruby-2.3.1
gem install bundler
bundle
```

#### Start the application
```
bin/rails s puma -p 3001
```
