require 'spec_helper'

describe Entities::SubEntities::Person do
  subject { Entities::SubEntities::Person.new }

  it { expect(subject.external?).to be(false) }
  it { expect(subject.entity_name).to eql('person') }

  describe 'map_to' do
    describe 'for an invalid entity name' do
      it { expect{ subject.map_to('lala', {}, nil) }.to raise_error("Impossible mapping from person to lala") }
    end

    describe 'for a valid entity name' do
      context 'for leads' do
        it 'calls normalize' do
          expect(Entities::SubEntities::LeadMapper).to receive(:normalize).with({})
          subject.map_to('lead', {}, nil)
        end
      end

      context 'for contacts' do
        context 'when entity has no organization_id' do
          it 'calls normalize' do
            expect(Entities::SubEntities::ContactMapper).to receive(:normalize).with({})
            subject.map_to('contact', {}, nil)
          end
        end

        context 'when entity has a organization_id field' do
          let(:organization) { create(:organization) }
          let(:sf_id) { '366AE3C' }
          let(:connec_id) { 'ab23-3er5-224fd' }

          context 'with no corresponding idmap' do
            it 'leaves the field blank' do
              expect(Entities::SubEntities::ContactMapper).to receive(:normalize).with({'organization_id' => ''})
              subject.map_to('contact', {'organization_id' => connec_id}, organization)
            end
          end

          context 'with a corresponding idmap' do
            let!(:idmap) { create(:idmap, organization: organization, connec_entity: 'organization', connec_id: connec_id, external_id: sf_id, external_entity: 'account') }

            it 'replace the field with the connec id' do
              expect(Entities::SubEntities::ContactMapper).to receive(:normalize).with({'organization_id' => sf_id})
              subject.map_to('contact', {'organization_id' => connec_id}, organization)
            end
          end
        end
      end
    end
  end

  describe 'update_external_entity' do
    let(:organization) { create(:organization) }
    let(:client) { Restforce.new }

    it 'calls client.update! when lead is not converted' do
      expect(client).to receive(:update!).with('external_name', {'IsConverted' => false, 'Id' => '3456'})
      subject.update_external_entity(client, {'IsConverted' => false}, '3456', 'external_name', organization)
    end

    it 'does not call client.update! when lead is converted' do
      expect(client).to_not receive(:update!)
      subject.update_external_entity(client, {'IsConverted' => true}, '3456', 'external_name', organization)
    end
  end

  describe 'create_external_entity' do
    let(:organization) { create(:organization) }
    let(:client) { Restforce.new }

    it 'adds a default company for leads' do
      expect(client).to receive(:create!).with('lead', {'Name' => 'Eric', 'Company' => 'Undefined'})
      subject.create_external_entity(client, {'Name' => 'Eric'}, 'lead', organization)
    end

    it 'does not add a default company for entity other than lead' do
      expect(client).to receive(:create!).with('not_lead', {'Name' => 'Eric'})
      subject.create_external_entity(client, {'Name' => 'Eric'}, 'not_lead', organization)
    end

  end
end