OmniAuth.config.logger = Rails.logger
OmniAuth.config.on_failure = OauthController.action(:oauth_failure)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :salesforce, ENV['salesforce_client_id'], ENV['salesforce_client_secret']
end
