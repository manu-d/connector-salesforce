Rails.application.routes.draw do
  mount Maestrano::Connector::Rails::Engine, at: '/'

  root 'home#index'
  get 'home/index' => 'home#index'
  get 'home/redirect_to_external' => 'home#redirect_to_external'
  get 'data/index' => 'data#index'
  get 'admin/index' => 'admin#index'
  put 'admin/update' => 'admin#update'
  post 'admin/synchronize' => 'admin#synchronize'
  put 'admin/toggle_sync' => 'admin#toggle_sync'

  match 'auth/:provider/request', to: 'oauth#request_omniauth', via: [:get, :post]
  match 'auth/:provider/callback', to: 'oauth#create_omniauth', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout_omniauth', to: 'oauth#destroy_omniauth', as: 'signout_omniauth', via: [:get, :post]

  # Sidekiq Admin
  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end
  mount Sidekiq::Web => '/sidekiq'
end
