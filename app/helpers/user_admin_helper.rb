module UserAdminHelper

  def is_admin?(user, organization)
    organization.member?(user) && session["role-#{organization.uid}"] && ['Admin', 'Super Admin'].include?(session["role-#{organization.uid}"])
  end

end
