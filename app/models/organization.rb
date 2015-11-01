class Organization < ActiveRecord::Base
  # Enable Maestrano for this group
  maestrano_group_via :provider, :uid do |group, maestrano|
    group.name = (maestrano.company_name.blank? ? "Default Group name" : maestrano.company_name)
    #group.country_alpha2 = maestrano.country
    #group.free_trial_end_at = maestrano.free_trial_end_at
    #group.some_required_field = 'some-appropriate-default-value'
  end
  
  #===================================
  # Associations
  #===================================
  has_many :user_organization_rels
  has_many :users, through: :user_organization_rels
  
  #===================================
  # Validation
  #===================================
  validates :name, presence: true
  
  def add_member(user)
    unless self.member?(user)
      self.user_organization_rels.create(user:user)
    end
  end
  
  def member?(user)
    self.user_organization_rels.where(user_id:user.id).count > 0
  end
  
  def remove_member(user)
    self.user_organization_rels.where(user_id:user.id).delete_all
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid).permit!).first_or_initialize.tap do |organization|
      organization.oauth_provider = auth.provider
      organization.oauth_uid = auth.uid
      organization.oauth_token = auth.credentials.token
      organization.refresh_token = auth.credentials.refresh_token
      organization.instance_url = auth.credentials.instance_url
      organization.save!
    end
  end
end
