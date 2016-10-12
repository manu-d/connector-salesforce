require 'spec_helper'

describe OauthController, :type => :controller do
  describe 'request_omniauth' do
    let(:organization) { create(:organization) }
    before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:current_organization).and_return(organization) }

    subject { get :request_omniauth, provider: 'salesforce' }

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

    subject { get :create_omniauth, provider: 'salesforce' }

    context 'when not admin' do
      before { allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(false) }

      it 'does nothing' do
        expect(Maestrano::Connector::Rails::External).to_not receive(:fetch_user)
        subject
      end
    end

    context 'when admin' do
      before {
        allow_any_instance_of(Maestrano::Connector::Rails::SessionHelper).to receive(:is_admin).and_return(true)
        allow_any_instance_of(Maestrano::Connector::Rails::Organization).to receive(:from_omniauth)
        allow(Maestrano::Connector::Rails::External).to receive(:fetch_company).and_return({'Name' => 'lala', 'Id' => 'idd'})
      }

      it 'update the organization with data from oauth and api calls' do
        expect_any_instance_of(Maestrano::Connector::Rails::Organization).to receive(:from_omniauth)
        expect(Maestrano::Connector::Rails::External).to receive(:fetch_company)
        subject
      end
    end
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
