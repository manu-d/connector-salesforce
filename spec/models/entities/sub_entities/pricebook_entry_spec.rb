require 'spec_helper'

describe Entities::SubEntities::PricebookEntry do
  describe 'class methods' do
    subject { Entities::SubEntities::PricebookEntry }

    it { expect(subject.external?).to be(true) }
    it { expect(subject.entity_name).to eql('PricebookEntry') }
    it { expect(subject.currency_check_fields).to eql(%w(sale_price purchase_price)) }
    it { expect(subject.object_name_from_external_entity_hash({'Product2Id' => '67AB'})).to eql('Price for 67AB') }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:external_client) { Restforce.new }
    subject { Entities::SubEntities::PricebookEntry.new(organization, nil, external_client) }

    describe 'get_external_entities' do
      let(:id1) { '567SQF' }
      let(:id2) { '12SQF' }
      before {
        allow(external_client).to receive(:describe).and_return({'fields' => []})
        allow(external_client).to receive(:query).and_return([{'Pricebook2Id' => id1}])
      }

      context 'for standard pricebook entry' do
        it 'does nothing' do
          allow(Entities::Item).to receive(:get_pricebook_id).and_return(id1)
          expect(subject.get_external_entities('')).to eql([{'Pricebook2Id' => id1}])
        end
      end

      context 'for not standard pricebook entry' do
        it 'deletes them' do
          allow(Entities::Item).to receive(:get_pricebook_id).and_return(id2)
          expect(subject.get_external_entities('')).to eql([])
        end
      end
    end

    describe 'map_to' do
      let(:sf_hash) {
        {
          "attributes"=>
          {
            "type"=>"PricebookEntry",
            "url"=>"/services/data/v32.0/sobjects/PricebookEntry/01u28000001VcFyAAK"
          },
          "Id"=>"01u28000001VcFyAAK",
          "Name"=>"Installation: Industrial - High",
          "Pricebook2Id"=>"01s28000005Cuu4AAC",
          "Product2Id"=>"01t28000000sB8mAAE",
          "UnitPrice"=>85000.0,
          "IsActive"=>true,
          "UseStandardPrice"=>false,
          "CreatedDate"=>"2015-11-29T15:24:02.000+0000",
          "CreatedById"=>"00528000001eP9OAAU",
          "LastModifiedDate"=>"2015-11-29T15:24:02.000+0000",
          "LastModifiedById"=>"00528000001eP9OAAU",
          "SystemModstamp"=>"2015-11-29T15:24:02.000+0000",
          "ProductCode"=>"IN7080",
          "IsDeleted"=>false
        }
      }

      let(:output_hash) {
        {
          :sale_price=>{:net_amount=>85000.0},
          :id=>[{id: "01t28000000sB8mAAE", provider: organization.oauth_provider, realm: organization.oauth_uid}]
        }.with_indifferent_access
      }

      it { expect(subject.map_to('Item',sf_hash)).to eql(output_hash) }
    end
  end
end
