require 'spec_helper'

describe Entities::SubEntities::PricebookEntry do
  describe 'class methods' do
    subject { Entities::SubEntities::PricebookEntry }

    it { expect(subject.external?).to be(true) }
    it { expect(subject.entity_name).to eql('PricebookEntry') }
    it { expect(subject.external_attributes).to be_a(Array) }
    it { expect(subject.object_name_from_external_entity_hash({'Product2Id' => '67AB'})).to eql('Price for 67AB') }
  end


  subject { Entities::SubEntities::PricebookEntry.new }

  describe 'link_and_filter_pricebook_entry' do
    let(:organization) { create(:organization) }
    let(:product_id) { '7766DEA' }

    context 'when idmap has no connec_id' do
      let!(:idmap) { create(:idmap, organization: organization, connec_id: nil, connec_entity: 'item', external_id: '133A', external_entity: 'pricebookentry') }

      describe 'when none is found' do
        it 'updates the idmap and remove then entity from the list' do
          expect(Maestrano::Connector::Rails::IdMap).to receive(:find_by).with(external_id: product_id, external_entity: 'product2', organization_id: organization.id)
          expect(subject.send(:link_and_filter_pricebook_entry, [{entity: {:Product2Id => product_id}, idmap: idmap}], organization)).to eql([])
          idmap.reload
          expect(idmap.message).to eql("Trying to push a price for a non existing or not pushed product (id: #{product_id})")
        end
      end

      describe 'when one is found' do
        let(:connec_id) { '9887eg-3565ef' }
        let!(:product_idmap) { create(:idmap, organization: organization, connec_id: connec_id, connec_entity: 'item', external_entity: 'product2', external_id: product_id) }

        it 'updates the pricebook entry idmap' do
          expect(subject.send(:link_and_filter_pricebook_entry, [{entity: {:Product2Id => product_id}, idmap: idmap}], organization)).to eql([{entity: {:Product2Id => product_id}, idmap: idmap}])
          idmap.reload
          expect(idmap.connec_id).to eql(connec_id)
        end
      end
    end

    context 'when idmap has a connec_id' do
      let(:connec_id) { '9887eg-3565ef' }
      let!(:idmap) { create(:idmap, organization: organization, connec_id: connec_id, connec_entity: 'item', external_id: '133A', external_entity: 'pricebookentry') }

      it 'does nothing' do
        expect(subject.send(:link_and_filter_pricebook_entry, [{entity: {:Product2Id => product_id}, idmap: idmap}], organization)).to eql([{entity: {:Product2Id => product_id}, idmap: idmap}])
      end
    end
  end

  describe 'get_external_entities' do
    let(:client) { Restforce.new }
    let(:organization) { create(:organization) }
    let(:id1) { '567SQF' }
    let(:id2) { '12SQF' }
    before {
      allow(client).to receive(:query).and_return([{'Pricebook2Id' => id1}])
    }

    context 'for standard pricebook entry' do
      it 'does nothing' do
        allow(Entities::Item).to receive(:get_pricebook_id).and_return(id1)
        expect(subject.get_external_entities(client, nil, organization)).to eql([{'Pricebook2Id' => id1}])
      end
    end

    context 'for not standard pricebook entry' do
      it 'deletes them' do
        allow(Entities::Item).to receive(:get_pricebook_id).and_return(id2)
        expect(subject.get_external_entities(client, nil, organization)).to eql([])
      end
    end
  end
end