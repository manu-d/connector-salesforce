require 'spec_helper'

describe OauthController, :type => :controller do
  describe 'request_omniauth' do
    let(:organization) { create(:organization) }
    before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:current_organization).and_return(organization) }

    subject { get :request_omniauth, {provider: 'salesforce', currency: 'AUD'} }

    context 'when not admin' do
      before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(false) }

      it {expect(subject).to redirect_to(root_url)}
    end

    context 'when admin' do
      before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(true) }

      it {expect(subject).to redirect_to("http://test.host/auth/salesforce?state=#{organization.uid}")}
    end
  end

  describe 'create_omniauth' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:current_user).and_return(user) }
    before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:current_organization).and_return(organization) }

    let(:credentials) { double(token: 'abc', refresh_token: 'def', instance_url: 'http://example.com') }
    let(:auth) { double(provider: 'salesforce', uid: '123', credentials: credentials) }
    before { request.env['omniauth.auth'] = auth }

    subject { get :create_omniauth, provider: 'salesforce' }

    context 'when not admin' do
      before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(false) }

      it 'does nothing' do
        expect(Maestrano::Connector::Rails::External).to_not receive(:fetch_user)
        subject
      end
    end

    context 'when admin' do
      before do
        allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(true)
      end

      it 'update the organization with data from oauth and api calls' do
        allow(Maestrano::Connector::Rails::External).to receive(:fetch_company).and_return({'Name' => 'lala', 'Id' => 'idd'})

        subject

        organization.reload

        expect(organization.oauth_name).to eql('lala')
        expect(organization.oauth_uid).to eql('idd')
      end
    end

    context 'when an error is thrown' do
      before do
        allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(true)
      end

      it 'displays API error to the user' do
        expect(Maestrano::Connector::Rails::External).to receive(:fetch_company).and_raise('API_DISABLED_FOR_ORG no API access')

        subject

        expect(flash[:danger]).to match "Your SalesForce account does not support API access, please upgrade your subscription<br/>Error detail: API_DISABLED_FOR_ORG no API access"
      end

      it 'displays generic errors to the user' do
        expect(Maestrano::Connector::Rails::External).to receive(:fetch_company).and_raise('Cannot fetch data')

        subject

        expect(flash[:danger]).to match "Your SalesForce account cannot be linked<br/>Error detail: Cannot fetch data"
      end
    end
  end

  describe 'oauth_failure' do
    subject { get :oauth_failure, error: 'Access Denied', error_description: "end-user denied authorization" }

    it {expect(subject).to redirect_to(root_url)}
  end

  describe 'destroy_omniauth' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization, oauth_uid: 'oauth_uid') }

    before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:current_organization).and_return(organization) }
    before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:current_user).and_return(user) }

    subject { get :destroy_omniauth }

    context 'when not admin' do
      before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(false) }

      it { expect { subject }.to_not change{ organization.oauth_uid } }
    end

    context 'when admin' do
      before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(true) }

      it {
        subject
        organization.reload
        expect(organization.oauth_uid).to be_nil
      }
    end
  end
end
