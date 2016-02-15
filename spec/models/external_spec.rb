require 'spec_helper'

describe Maestrano::Connector::Rails::External do

  describe 'class methods' do
    subject { Maestrano::Connector::Rails::External }

    describe 'external_name' do
      it { expect(subject.external_name).to eql('SalesForce') }
    end

    describe 'get_client' do
      let(:organization) { create(:organization) }

      it 'creates a restforce client' do
        expect(Restforce).to receive(:new)
        subject.get_client(organization)
      end
    end

    describe 'fetch_user' do
      let(:organization) { create(:organization) }
      let(:client) { Restforce.new }
      let(:auth) { {} }
      before {
        allow(auth).to receive(:id).and_return('aa-ll')
        allow(auth).to receive(:body)
        allow(Maestrano::Connector::Rails::External).to receive(:get_client).and_return(client)
      }

      it {
        allow(client).to receive(:authenticate!).and_return(auth)
        allow(client).to receive(:get).and_return(auth)
        expect(client).to receive(:authenticate!)
        expect(client).to receive(:get).with('aa-ll')
        subject.fetch_user(organization)
      }
    end

    describe 'fetch_company' do
      let(:organization) { create(:organization) }
      let(:client) { Restforce.new }
      before {
        allow(Maestrano::Connector::Rails::External).to receive(:get_client).and_return(client)
      }

      it 'get the company' do
        allow(client).to receive(:query).and_return([0])
        expect(client).to receive(:query)
        subject.fetch_company(organization)
      end
    end
  end

end