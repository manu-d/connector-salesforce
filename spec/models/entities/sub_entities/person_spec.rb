require 'spec_helper'

describe Entities::SubEntities::Person do
  describe 'class methods' do
    subject { Entities::SubEntities::Person }

    it { expect(subject.external?).to be(false) }
    it { expect(subject.entity_name).to eql('person') }
    it { expect(subject.object_name_from_connec_entity_hash({'first_name' => 'Eric', 'last_name' => 'Mno'})).to eql('Eric Mno') }
  end

  describe 'instance methods' do
    subject { Entities::SubEntities::Person.new }

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

    describe 'mapping' do
      let!(:organization) { create(:organization) }

      describe 'to contacts' do
        let(:connec_hash) {
          {
            "id"=>"eb8004d1-78db-0133-67ba-0620e3ce3a45",
            "code"=>"PE3",
            "status"=>"ACTIVE",
            "title"=>"Mr.",
            "first_name"=>"Avi",
            "last_name"=>"Green",
            "job_title"=>"CFO",
            "birth_date"=>"1929-06-07T00:00:00Z",
            "organization_id"=>connec_org_id,
            "is_customer"=>true,
            "is_supplier"=>false,
            "is_lead"=>false,
            "address_work"=>
            {
            "billing"=>
              {"line1"=>"1302 Avenue of the Americas \nNew York, NY 10019\nUSA"},
             "billing2"=>{},
             "shipping"=>{},
             "shipping2"=>{}
            },
            "address_home"=>
            {
            "billing"=>{}, "billing2"=>{}, "shipping"=>{}, "shipping2"=>{}
            },
            "email"=>{"address"=>"agreen@uog.com"},
            "website"=>{},
            "phone_work"=>
            {
            "landline"=>"(212) 842-5500",
             "mobile"=>"(212) 842-2383",
             "fax"=>"(212) 842-5501"
             },
            "phone_home"=>{},
            "lead_status_changes"=>[],
            "referred_leads"=>[],
            "opportunities"=>[],
            "notes"=>[],
            "tasks"=>[],
            "created_at"=>"2015-11-29T15:29:35Z",
            "updated_at"=>"2015-11-29T16:00:18Z",
            "group_id"=>"cld-94m8",
            "channel_id"=>"org-fg5b",
            "resource_type"=>"people"
          }
        }

        let(:connec_org_id) { 'aaaa-bbbb' }
        let(:ext_org_id) { '0012800000CaxiJAAR' }
        let!(:org_idmap) { create(:idmap, organization: organization, connec_entity: 'organization', external_entity: 'account', connec_id: connec_org_id, external_id: ext_org_id) }

        let(:output_hash) {
          {
            :AccountId=>ext_org_id,
            :Salutation=>"Mr.",
            :FirstName=>"Avi",
            :LastName=>"Green",
            :Title=>"CFO",
            :Birthdate=>"1929-06-07T00:00:00Z",
            :MailingStreet=>"1302 Avenue of the Americas \nNew York, NY 10019\nUSA",
            :Email=>"agreen@uog.com",
            :Phone=>"(212) 842-5500",
            :MobilePhone=>"(212) 842-2383",
            :Fax=>"(212) 842-5501"
          }
        }

        it { expect(subject.map_to('contact', connec_hash, organization)).to eql(output_hash) }
      end
    end
  end
end