require 'spec_helper'

describe Maestrano::Connector::Rails::Entity do

  describe 'class methods' do
    subject { Maestrano::Connector::Rails::Entity }

    describe 'id_from_external_entity_hash' do
      it { expect(subject.id_from_external_entity_hash({'Id' => '1234'})).to eql('1234') }
    end

    describe 'last_update_date_from_external_entity_hash' do
      it {
        Timecop.freeze(Date.today) do
          expect(subject.last_update_date_from_external_entity_hash({'LastModifiedDate' => 1.hour.ago})).to eql(1.hour.ago)
        end
      }
    end
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:external_client) { Restforce.new }
    let(:opts) { {} }
    subject { Maestrano::Connector::Rails::Entity.new(organization, nil, external_client, opts) }
    let(:external_name) { 'external_name' }
    before {
      allow(subject.class).to receive(:external_entity_name).and_return(external_name)
      allow(external_client).to receive(:describe).and_return({'fields' => [{'name' => 'Id'}, {'name' => 'LastName'}]})
    }

    describe 'get_external_entities' do
      context 'with full sync option' do
        let(:opts) { {full_sync: true} }
        it 'uses a full query' do
          expect(external_client).to receive(:query).with(/select Id, LastName from #{external_name}/i)
          subject.get_external_entities(nil)
        end
      end

      context 'without option' do
        context 'without last sync' do
          it 'uses a full query' do
            expect(external_client).to receive(:query).with(/select Id, LastName from #{external_name}/i)
            subject.get_external_entities(nil)
          end
        end

        context 'with a last sync' do
          let(:last_sync) { create(:synchronization, updated_at: 1.hour.ago) }

          it 'uses get updated' do
            Timecop.freeze(Date.today) do
              allow(external_client).to receive(:get_updated).and_return({'ids' => []})
              expect(external_client).to receive(:get_updated).with(external_name, last_sync.updated_at, Time.now)
              subject.get_external_entities(last_sync)
            end
          end

          it 'calls find on received ids' do
            allow(external_client).to receive(:get_updated).and_return({'ids' => [3, 5, 6]})
            expect(external_client).to receive(:find).with(external_name, 3)
            expect(external_client).to receive(:find).with(external_name, 5)
            expect(external_client).to receive(:find).with(external_name, 6)
            subject.get_external_entities(last_sync)
          end

          it 'returns the entities' do
            allow(external_client).to receive(:get_updated).and_return({'ids' => [3, 5, 6]})
            allow(external_client).to receive(:find).and_return({'FirstName' => 'John'})
            expect(subject.get_external_entities(last_sync)).to eql([{'FirstName' => 'John'}, {'FirstName' => 'John'}, {'FirstName' => 'John'}])
          end
        end
      end
    end

    describe 'create_external_entity' do
      it 'calls create!' do
        expect(external_client).to receive(:create!).with(external_name, {})
        subject.create_external_entity({}, external_name)
      end
    end

    describe 'update_external_entity' do
      it 'calls update! with the id' do
        expect(external_client).to receive(:update!).with(external_name, {'Id' => '3456'})
        subject.update_external_entity({}, '3456', external_name)
      end
    end
  end

end