class User < ActiveRecord::Base
  # Enable Maestrano for this user
  maestrano_user_via :provider, :uid do |user, maestrano|
    user.uid = maestrano.uid
    user.provider = maestrano.provider
    user.first_name = maestrano.first_name
    user.last_name = maestrano.last_name
    user.email = maestrano.email
    
    # user.country_alpha2 = maestrano.country
    # user.some_required_field = 'some-appropriate-default-value'
  end

  #===================================
  # Associations
  #===================================
  has_many :user_organization_rels
  has_many :organizations, through: :user_organization_rels

  #===================================
  # Validation
  #===================================
  validates :email, presence: true

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid).permit!).first_or_initialize.tap do |user|
      user.oauth_provider = auth.provider
      user.oauth_uid = auth.uid
      user.oauth_token = auth.credentials.token
      user.refresh_token = auth.credentials.refresh_token
      user.instance_url = auth.credentials.instance_url
      user.save!
    end
  end
end
