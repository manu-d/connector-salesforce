class OauthController < ApplicationController

  def request_omniauth
    if params[:currency].blank?
      flash[:danger] = "You must specify a default currency"
      return redirect_to root_url
    end
    if is_admin
      current_organization.update_attributes(default_currency: params[:currency][/\((.*?)\)/m, 1])
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
      auth = request.env["omniauth.auth"]
      current_organization.oauth_provider = auth.provider
      current_organization.oauth_uid = auth.uid
      current_organization.oauth_token = auth.credentials.token
      current_organization.refresh_token = auth.credentials.refresh_token
      current_organization.instance_url = auth.credentials.instance_url

      # Fetch SalesForce company name
      company = Maestrano::Connector::Rails::External.fetch_company(current_organization)
      current_organization.oauth_name = company['Name']
      current_organization.oauth_uid = company['Id']

      unless current_organization.save
        # Display the error to the user
        Maestrano::Connector::Rails::ConnectorLogger.log('info', current_organization, "Error in create_omniauth: #{current_organization.errors.full_messages}")
        flash[:danger] = "Your SalesForce account \"#{company['Name']}\" cannot be linked: #{current_organization.errors.full_messages}"
      end
    rescue => e
      if e.message.include?('API_DISABLED_FOR_ORG')
        # API access is disabled
        Maestrano::Connector::Rails::ConnectorLogger.log('warn', current_organization, "Error in create_omniauth, API Access disabled: #{e.message}. #{e.backtrace.join("\n")}")
        errors = [
          'Your SalesForce account does not support API access, please upgrade your subscription',
          "Error detail: #{e.message}"
        ]
        flash[:danger] = errors.join("<br/>")
      else
        Maestrano::Connector::Rails::ConnectorLogger.log('warn', current_organization, "Error in create_omniauth: #{e.message}. #{e.backtrace.join("\n")}")
        errors = [
          'Your SalesForce account cannot be linked',
          "Error detail: #{e.message}"
        ]
        flash[:danger] = errors.join("<br/>")
      end
    end

    redirect_to root_url
  end

  def oauth_failure
    flash[:danger] = [params[:error], params[:error_description]].join(': ')
    redirect_to root_url
  end

  # Unlink Organization from SalesForce
  def destroy_omniauth
    return redirect_to root_url unless is_admin

    current_organization.clear_omniauth

    redirect_to root_url
  end
end
