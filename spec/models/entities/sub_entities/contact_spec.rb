require 'spec_helper'

describe Entities::SubEntities::Contact do
  describe 'class methods' do
    subject { Entities::SubEntities::Contact }

    it { expect(subject.external?).to be(true) }
    it { expect(subject.entity_name).to eql('contact') }
    it { expect(subject.external_attributes).to be_a(Array) }
    it { expect(subject.object_name_from_external_entity_hash({'FirstName' => 'John', 'LastName' => 'A'})).to eql('John A') }
  end

  describe 'instance methods' do
    subject { Entities::SubEntities::Contact.new }
    let!(:organization) { create(:organization) }

    describe 'map_to' do
      let(:sf_hash) {
        {
          "attributes"=>
          {
            "type"=>"Contact",
            "url"=>"/services/data/v32.0/sobjects/Contact/0032800000ABs2zAAD"
          },
          "Id"=>"0032800000ABs2zAAD",
          "IsDeleted"=>false,
          "MasterRecordId"=>nil,
          "AccountId"=>ext_org_id,
          "LastName"=>"Gonzalez",
          "FirstName"=>"Rose",
          "Salutation"=>"Ms.",
          "Name"=>"Rose Gonzalez",
          "OtherStreet"=>nil,
          "OtherCity"=>nil,
          "OtherState"=>nil,
          "OtherPostalCode"=>nil,
          "OtherCountry"=>nil,
          "OtherLatitude"=>nil,
          "OtherLongitude"=>nil,
          "OtherAddress"=>nil,
          "MailingStreet"=>"313 Constitution Place\nAustin, TX 78767\nUSA",
          "MailingCity"=>nil,
          "MailingState"=>nil,
          "MailingPostalCode"=>nil,
          "MailingCountry"=>nil,
          "MailingLatitude"=>nil,
          "MailingLongitude"=>nil,
          "MailingAddress"=>
          {
            "city"=>nil,
            "country"=>nil,
            "countryCode"=>nil,
            "geocodeAccuracy"=>nil,
            "latitude"=>nil,
            "longitude"=>nil,
            "postalCode"=>nil,
            "state"=>nil,
            "stateCode"=>nil,
            "street"=>"313 Constitution Place\nAustin, TX 78767\nUSA"
          },
          "Phone"=>"(512) 757-6000",
          "Fax"=>"(512) 757-9000",
          "MobilePhone"=>"(512) 757-9340",
          "HomePhone"=>nil,
          "OtherPhone"=>nil,
          "AssistantPhone"=>nil,
          "ReportsToId"=>nil,
          "Email"=>"rose@edge.com",
          "Title"=>"SVP, Procurement",
          "Department"=>nil,
          "AssistantName"=>nil,
          "LeadSource"=>nil,
          "Birthdate"=>"1963-11-08",
          "Description"=>nil,
          "OwnerId"=>"00528000001eP9OAAU",
          "CreatedDate"=>"2015-12-04T18:08:20.000+0000",
          "CreatedById"=>"00528000001eP9OAAU",
          "LastModifiedDate"=>"2015-12-04T18:08:20.000+0000",
          "LastModifiedById"=>"00528000001eP9OAAU",
          "SystemModstamp"=>"2015-12-04T18:08:20.000+0000",
          "LastActivityDate"=>nil,
          "LastCURequestDate"=>nil,
          "LastCUUpdateDate"=>nil,
          "LastViewedDate"=>"2015-12-17T10:08:56.000+0000",
          "LastReferencedDate"=>"2015-12-17T10:08:56.000+0000",
          "EmailBouncedReason"=>nil,
          "EmailBouncedDate"=>nil,
          "IsEmailBounced"=>false,
          "PhotoUrl"=>"/services/images/photo/0032800000ABs2zAAD",
          "Jigsaw"=>nil,
          "JigsawContactId"=>nil,
          "CleanStatus"=>"Pending",
          "Level__c"=>nil,
          "Languages__c"=>nil
        }
      }

      let(:connec_org_id) { 'aaaa-bbbb' }
      let(:ext_org_id) { '0012800000CaxiJAAR' }
      let!(:org_idmap) { create(:idmap, organization: organization, connec_entity: 'organization', external_entity: 'account', connec_id: connec_org_id, external_id: ext_org_id) }

      let(:output_hash) {
        {
          :opts=>{"create_default_organization"=>true},
          :organization_id=>connec_org_id,
          :title=>"Ms.",
          :first_name=>"Rose",
          :last_name=>"Gonzalez",
          :job_title=>"SVP, Procurement",
          :birth_date=>Date.parse('1963-11-08').to_time.iso8601,
          :address_work=>
          {
            :billing=>{:line1=>"313 Constitution Place\nAustin, TX 78767\nUSA"}
          },
          :email=>{:address=>"rose@edge.com"},
          :phone_work=>
          {
            :landline=>"(512) 757-6000",
            :mobile=>"(512) 757-9340",
            :fax=>"(512) 757-9000"
          }
        }
      }

      it { expect(subject.map_to('person',sf_hash, organization)).to eql(output_hash) }
    end

  end
end