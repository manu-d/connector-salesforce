require 'spec_helper'

describe Maestrano::Connector::Rails::Entity do

  describe 'class methods' do
    subject { Maestrano::Connector::Rails::Entity }

    describe 'id_from_external_entity_hash' do
      it { expect(subject.id_from_external_entity_hash({'Id' => '1234'})).to eql('1234') }
    end

    describe 'last_update_date_from_external_entity_hash' do
      it 'store the LastModifiedDate' do
        Timecop.freeze(Date.today) do
          expect(subject.last_update_date_from_external_entity_hash({'LastModifiedDate' => 1.hour.ago})).to eql(1.hour.ago)
        end
      end
    end
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:external_client) { Restforce.new }
    let(:opts) { {} }
    subject { Maestrano::Connector::Rails::Entity.new(organization, nil, external_client, opts) }
    let(:external_name) { 'external_name' }

    before(:each) do
      allow(external_client).to receive(:describe).and_return({'fields' => [{'name' => 'Id'}, {'name' => 'LastName'}]})
    end

    describe 'get_external_entities' do
      context 'with full sync option' do
        let(:opts) { {full_sync: true} }
        it 'uses a full query' do
          expect(external_client).to receive(:query).with(/select Id, LastName from #{external_name}/i)
          subject.get_external_entities(external_name)
        end
      end

      context 'without option' do
        context 'without last sync' do
          it 'uses a full query' do
            expect(external_client).to receive(:query).with(/select Id, LastName from #{external_name}/i)
            subject.get_external_entities(external_name)
          end
        end

        context 'with a last sync' do
          let(:last_sync) { create(:synchronization, updated_at: 1.hour.ago) }

          it 'uses get updated' do

            Timecop.freeze(Date.today) do
              allow(SecureRandom).to receive(:uuid).and_return('4d33acc5-3448-46d4-ad94-c2b37630xx9x', '4d33acc5-3448-46d4-ad94-c2b37630xx9y')
              # stub_request(:get, "#{Maestrano['local'].param('api.host')}/api/v1/account/groups/").to_return({status: 200, body: "{}", headers: {}})

              allow(external_client).to receive(:get_updated).and_return({'ids' => []})
              expect(external_client).to receive(:get_updated).with(external_name, last_sync.updated_at - 2.minutes, Time.now + 2.minutes)
              subject.get_external_entities(external_name, last_sync.updated_at)
            end
          end

          context 'when last synch date is older than 30 days' do
            let(:last_sync) { create(:synchronization, updated_at: 45.days.ago) }

            it 'defaults to 30 days' do
              allow(SecureRandom).to receive(:uuid).and_return('4d33acc5-3448-46d4-ad94-c2b37630xx9c', '4d33acc5-3448-46d4-ad94-c2b37630xx9d')
              # stub_request(:get, "#{Maestrano['local'].param('api.host')}/api/v1/account/groups/{id}").to_return({status: 200, body: "{}", headers: {}})

              Timecop.freeze(Date.today) do
                allow(external_client).to receive(:get_updated).and_return({'ids' => []})
                expect(external_client).to receive(:get_updated).with(external_name, 30.days.ago - 2.minutes, Time.now + 2.minutes)
                subject.get_external_entities(external_name, last_sync.updated_at)
              end
            end
          end



          it 'calls find on received ids' do
            allow(SecureRandom).to receive(:uuid).and_return('4d33acc5-3448-46d4-ad94-c2b37630xx9w', '4d33acc5-3448-46d4-ad94-c2b37630xx9z')
            # stub_request(:get, "#{Maestrano['local'].param('api.host')}/api/v1/account/groups/").to_return({status: 200, body: "{}", headers: {}})

            allow(external_client).to receive(:get_updated).and_return({'ids' => [3, 5, 6]})
            expect(external_client).to receive(:find).with(external_name, 3)
            expect(external_client).to receive(:find).with(external_name, 5)
            expect(external_client).to receive(:find).with(external_name, 6)
            subject.get_external_entities(external_name, last_sync.updated_at)
          end

          it 'returns the entities' do
            allow(SecureRandom).to receive(:uuid).and_return('4d33acc5-3448-46d4-ad94-c2b37630yy9w', '4d33acc5-3448-46d4-ad94-c2b37630yy9z')
            # stub_request(:get, "#{Maestrano['local'].param('api.host')}/api/v1/account/groups/").to_return({status: 200, body: "{}", headers: {}})
            stub_request(:get, "https://maestrano.com/api/v1/account/groups/4d33acc5-3448-46d4-ad94-c2b37630yy9w")
              .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic Og==', 'User-Agent'=>'Ruby'})
              .to_return({status: 200, body: "{}", headers: {}})
            stub_request(:get, "https://maestrano.com/api/v1/account/groups/4d33acc5-3448-46d4-ad94-c2b37630yy9z")
              .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic Og==', 'User-Agent'=>'Ruby'})
              .to_return({status: 200, body: "{}", headers: {}})

            allow(external_client).to receive(:get_updated).and_return({'ids' => [3, 5, 6]})
            allow(external_client).to receive(:find).and_return({'FirstName' => 'John'})
            expect(subject.get_external_entities(external_name, last_sync.updated_at)).to eql([{'FirstName' => 'John'}, {'FirstName' => 'John'}, {'FirstName' => 'John'}])
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
