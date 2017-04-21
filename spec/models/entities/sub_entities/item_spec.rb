require 'spec_helper'

describe Entities::SubEntities::Item do
  describe 'class methods' do
    subject { Entities::SubEntities::Item }

    it { expect(subject.external?).to be(false) }
    it { expect(subject.entity_name).to eql('Item') }
    it { expect(subject.object_name_from_connec_entity_hash({'reference' => 'M123', 'name' => 'Mno'})).to eql('[M123] Mno') }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:external_client) { Restforce.new }
    subject { Entities::SubEntities::Item.new(organization, nil, external_client) }

    describe 'link_to_pricebook' do
      let(:pricebook_id) { 'PR1C3B00K-1D' }
      before {
        allow(Entities::Item).to receive(:get_pricebook_id).and_return(pricebook_id)
      }

      context 'for a creation' do
        let!(:idmap) { create(:idmap, organization: organization, external_id: nil) }
        let!(:product_idmap) { Entities::SubEntities::Product2.create_idmap(organization_id: organization.id, connec_id: idmap.connec_id, external_id: 'abc', connec_entity: 'item') }

        it 'sets a pricebookID' do
          expect(subject.send(:link_to_pricebook, [{entity: {'price' => 45}, idmap: idmap}])).to eql([{entity: {'price' => 45, 'Pricebook2Id' => pricebook_id, 'Product2Id' => product_idmap.external_id}, idmap: idmap}])
        end
      end
    end

    describe 'mapping' do
      describe 'to_pricebook' do
        let(:connec_hash) {
          {
            "id"=>"4a38d6f1-7d78-0133-6440-0620e3ce3a45",
            "code"=>"GC1040",
            "name"=>"GenWatt Diesel 200kW",
            "status"=>"ACTIVE",
            "is_inventoried"=>false,
            "sale_price"=>{"net_amount"=>25000.0, "currency"=>"USD"},
            "purchase_price"=>{"currency"=>"USD"},
            "created_at"=>"2015-12-05T12:19:00Z",
            "updated_at"=>"2015-12-05T12:50:01Z",
            "group_id"=>"cld-94m8",
            "channel_id"=>"org-fg5b",
            "resource_type"=>"items"
          }
        }

        let(:output_hash) {
          {:UnitPrice=>25000.0}.with_indifferent_access
        }

        it { expect(subject.map_to('PricebookEntry', connec_hash)).to eql(output_hash) }
      end

      describe 'to Product2' do
        let(:connec_hash) {
          {
            "id"=>"4a38d6f1-7d78-0133-6440-0620e3ce3a45",
            "code"=>"GC1040",
            "reference"=>"GC1040",
            "name"=>"GenWatt Diesel 200kW",
            "status"=>"ACTIVE",
            "is_inventoried"=>false,
            "sale_price"=>{"net_amount"=>25000.0, "currency"=>"USD"},
            "purchase_price"=>{"currency"=>"USD"},
            "created_at"=>"2015-12-05T12:19:00Z",
            "updated_at"=>"2015-12-05T12:50:01Z",
            "group_id"=>"cld-94m8",
            "channel_id"=>"org-fg5b",
            "resource_type"=>"items"
          }
        }

        let(:output_hash) {
          {
            ProductCode: 'GC1040',
            Name: 'GenWatt Diesel 200kW',
            IsActive: true
          }.with_indifferent_access
        }

        it { expect(subject.map_to('Product2', connec_hash)).to eql(output_hash) }
      end
    end
  end
end