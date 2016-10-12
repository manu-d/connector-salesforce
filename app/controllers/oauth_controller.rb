class OauthController < ApplicationController

  def request_omniauth
    if is_admin
      auth_params = {state: current_organization.uid}
      url_params = URI.escape(auth_params.collect{|k,v| "#{k}=#{v}"}.join('&'))

      redirect_to "/auth/#{params[:provider]}?#{url_params}", id: "sign_in"
    else
      redirect_to root_url
    end
  end

  # Link an Organization to SalesForce OAuth account
  def create_omniauth
    return redirect_to root_url unless is_admin

    begin
      # Update organization oauth details
      current_organization.from_omniauth(env["omniauth.auth"])

      # Fetch SalesForce company name
      company = Maestrano::Connector::Rails::External.fetch_company(current_organization)

      if current_organization.valid?
        current_organization.update(oauth_name: company['Name'], oauth_uid: company['Id'])
      else
        # Display the error to the user
        Maestrano::Connector::Rails::ConnectorLogger.log('info', current_organization, "Error in create_omniauth: #{current_organization.errors.full_messages}")
        flash[:danger] = "Your SalesForce account \"#{company['Name']}\" cannot be linked: #{current_organization.errors.full_messages}"
      end
    rescue => e
      empty_organization_fields(current_organization)
      Maestrano::Connector::Rails::ConnectorLogger.log('warn', current_organization, "Error in create_omniauth: #{e.message}. #{e.backtrace.join("\n")}")
      flash[:danger] = "Your SalesForce account cannot be linked (#{e.message})"
    end

    redirect_to root_url
  end

  # Unlink Organization from SalesForce
  def destroy_omniauth
    return redirect_to root_url unless is_admin

    current_organization.clear_omniauth

    redirect_to root_url
  end
end
