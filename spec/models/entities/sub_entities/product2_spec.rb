require 'spec_helper'

describe Entities::SubEntities::Product2 do
  describe 'class methods' do
    subject { Entities::SubEntities::Product2 }

    it { expect(subject.external?).to be(true) }
    it { expect(subject.entity_name).to eql('Product2') }
    it { expect(subject.object_name_from_external_entity_hash({'Name' => 'Stuff', 'ProductCode' => '67AB'})).to eql('[67AB] Stuff') }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization, default_currency: 'AMD') }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {organization: organization} }
    subject { Entities::SubEntities::Product2.new(organization, connec_client, external_client, opts) }

    describe 'mapping to item' do
      let(:sf_hash) {
        {
          "attributes"=>
          {
            "type"=>"Product2",
            "url"=>"/services/data/v32.0/sobjects/Product2/01t28000000yjJ5AAI"
          },
          "Id"=>"01t28000000yjJ5AAI",
          "Name"=>"SLA: Platinum",
          "ProductCode"=>"SL9080",
          "Description"=>nil,
          "IsActive"=>false,
          "CreatedDate"=>"2015-12-05T13:09:45.000+0000",
          "CreatedById"=>"00528000001eP9OAAU",
          "LastModifiedDate"=>"2015-12-05T13:09:45.000+0000",
          "LastModifiedById"=>"00528000001eP9OAAU",
          "SystemModstamp"=>"2015-12-05T13:09:45.000+0000",
          "Family"=>nil,
          "IsDeleted"=>false,
          "LastViewedDate"=>"2015-12-05T13:18:09.000+0000",
          "LastReferencedDate"=>"2015-12-05T13:18:09.000+0000"
         }
      }

      let(:output_hash) {
        {
          reference: "SL9080",
          name: "SLA: Platinum",
          purchase_price:  {"currency"=>"AMD"},
          reference:  "SL9080",
          sale_price:  {"currency"=>"AMD"},
          id:  [{"id"=>"01t28000000yjJ5AAI", "provider"=>organization.oauth_provider, "realm"=>organization.oauth_uid}]
        }.with_indifferent_access
      }

      it { expect(subject.map_to('Item', sf_hash)).to eql(output_hash) }
    end
  end
end
