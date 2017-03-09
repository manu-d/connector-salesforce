require 'spec_helper'

describe Entities::SubEntities::Person do
  describe 'class methods' do
    subject { Entities::SubEntities::Person }

    it { expect(subject.external?).to be(false) }
    it { expect(subject.entity_name).to eql('Person') }
    it { expect(subject.object_name_from_connec_entity_hash({'first_name' => 'Eric', 'last_name' => 'Mno'})).to eql('Eric Mno') }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:external_client) { Restforce.new }
    subject { Entities::SubEntities::Person.new(organization, nil, external_client) }

    describe 'update_external_entity' do
      it 'calls client.update! when lead is not converted' do
        expect(external_client).to receive(:update!).with('external_name', {'IsConverted' => false, 'Id' => '3456'})
        subject.update_external_entity({'IsConverted' => false}, '3456', 'external_name')
      end

      it 'does not call client.update! when lead is converted' do
        expect(external_client).to_not receive(:update!)
        subject.update_external_entity({'IsConverted' => true}, '3456', 'external_name')
      end
    end

    describe 'create_external_entity' do
      it 'adds a default company for leads' do
        expect(external_client).to receive(:create!).with('Lead', {'Name' => 'Eric', 'Company' => 'Undefined'})
        subject.create_external_entity({'Name' => 'Eric'}, 'Lead')
      end

      it 'does not add a default company for entity other than lead' do
        expect(external_client).to receive(:create!).with('not_lead', {'Name' => 'Eric'})
        subject.create_external_entity({'Name' => 'Eric'}, 'not_lead')
      end
    end

    describe 'mapping' do
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
            "organization_id"=>org_id,
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

        let(:org_id) { 'aaaa-bbbb' }

        let(:output_hash) {
          {
            :AccountId=>org_id,
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
          }.with_indifferent_access
        }

        it { expect(subject.map_to('Contact', connec_hash)).to eql(output_hash) }
      end

      describe 'to leads' do
        let(:connec_hash) {
          {
            "id"=>"18b7c3c1-7cd8-0133-dd04-0620e3ce3a45",
            "code"=>"PE192",
            "status"=>"ACTIVE",
            "title"=>"Ms",
            "first_name"=>"Phyllis",
            "last_name"=>"Cotton",
            "job_title"=>"CFO",
            "is_customer"=>true,
            "is_supplier"=>false,
            "is_lead"=>true,
            "address_work"=>
            {
            "billing"=>{"region"=>"VA", "country"=>"United States"},
             "billing2"=>{},
             "shipping"=>{},
             "shipping2"=>{}
            },
            "address_home"=>
            {
            "billing"=>{}, "billing2"=>{}, "shipping"=>{}, "shipping2"=>{}
            },
            "email"=>{"address"=>"pcotton@abbottins.net"},
            "website"=>{},
            "phone_work"=>{"landline"=>"(703) 757-1000", "mobile"=>"0777-225474189"},
            "phone_home"=>{},
            "lead_status"=>"",
            "lead_source"=>"Web",
            "lead_status_changes"=>
            [
              {"status"=>"Open - Not Contacted", "created_at"=>"2015-12-04T17:12:18Z"}
            ],
            "lead_conversion_date" => "2016-12-04T17:12:18Z",
            "referred_leads"=>[],
            "opportunities"=>[],
            "notes"=>[],
            "tasks"=>[],
            "created_at"=>"2015-12-04T17:12:18Z",
            "updated_at"=>"2015-12-04T17:12:18Z",
            "group_id"=>"cld-94m8",
            "channel_id"=>"org-fg5b",
            "resource_type"=>"people"
          }.with_indifferent_access
        }

        let(:output_hash) {
          {
            :Salutation=>"Ms",
            :FirstName=>"Phyllis",
            :LastName=>"Cotton",
            :Title=>"CFO",
            :State=>"VA",
            :IsConverted=> true,
            :ConvertedDate => "2016-12-04T17:12:18Z",
            :Country=>"United States",
            :Email=>"pcotton@abbottins.net",
            :Phone=>"(703) 757-1000",
            :MobilePhone=>"0777-225474189",
            :LeadSource=>"Web",
            :Status=>"Open - Not Contacted",
          }.with_indifferent_access
        }

        let(:connec_hash_with_status) {
          connec_hash.merge({"lead_status"=>"Open - Not Contacted"})
        }

        it { expect(subject.map_to('Lead', connec_hash)).to eql(output_hash) }
        it { expect(subject.map_to('Lead', connec_hash_with_status)).to eql(output_hash) }
      end
    end
  end
end
