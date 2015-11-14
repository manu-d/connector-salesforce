module SessionHelper

  def is_admin?(user, organization)
    organization.member?(user) && session[:"role_#{organization.uid}"] && ['Admin', 'Super Admin'].include?(session[:"role_#{organization.uid}"])
  end

  def current_organization
    Organization.find_by_uid(session[:org_uid])
  end

end
