require 'spec_helper'

describe Entities::SubEntities::Lead do
  describe 'class methods' do
    subject { Entities::SubEntities::Lead }

    it { expect(subject.external?).to be(true) }
    it { expect(subject.entity_name).to eql('Lead') }
    it { expect(subject.object_name_from_external_entity_hash({'FirstName' => 'John', 'LastName' => 'A'})).to eql('John A') }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:connec_client) { Maestrano::Connec::Client[organization.tenant].new(organization.uid) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Entities::SubEntities::Lead.new(organization, connec_client, external_client, opts) }

    describe 'mapping to Connec!' do
      let(:sf_hash) {
        {
          "attributes"=>
            {
              "type"=>"Lead",
              "url"=>"/services/data/v32.0/sobjects/Lead/00Q28000003FcanEAC"
            },
            "Id"=>"00Q28000003FcanEAC",
            "IsDeleted"=>false,
            "MasterRecordId"=>nil,
            "LastName"=>"Glimpse",
            "FirstName"=>"Jeff",
            "Salutation"=>"Mr",
            "Name"=>"Jeff Glimpse",
            "Title"=>"SVP, Procurement",
            "Company"=>"Jackson Controls",
            "Street"=>nil,
            "City"=>nil,
            "State"=>nil,
            "PostalCode"=>nil,
            "Country"=>"Taiwan, Republic Of China",
            "Latitude"=>nil,
            "Longitude"=>nil,
            "Address"=>
            {
              "city"=>nil,
              "country"=>"Taiwan, Republic Of China",
              "countryCode"=>nil,
              "geocodeAccuracy"=>nil,
              "latitude"=>nil,
              "longitude"=>nil,
              "postalCode"=>nil,
              "state"=>nil,
              "stateCode"=>nil,
              "street"=>nil
            },
            "Phone"=>"886-2-25474189",
            "MobilePhone"=>"0777-225474189",
            "Email"=>"jeffg@jackson.com",
            "Website"=>nil,
            "PhotoUrl"=>"/services/images/photo/00Q28000003FcanEAC",
            "Description"=>nil,
            "LeadSource"=>"Phone Inquiry",
            "Status"=>"Open - Not Contacted",
            "Industry"=>nil,
            "Rating"=>nil,
            "AnnualRevenue"=>nil,
            "NumberOfEmployees"=>nil,
            "OwnerId"=>"00528000001eP9OAAU",
            "IsConverted"=>false,
            "ConvertedDate"=>"2016-11-29T15:24:02.000+0000",
            "ConvertedAccountId"=>nil,
            "ConvertedContactId"=>nil,
            "ConvertedOpportunityId"=>nil,
            "IsUnreadByOwner"=>false,
            "CreatedDate"=>"2015-11-29T15:24:02.000+0000",
            "CreatedById"=>"00528000001eP9OAAU",
            "LastModifiedDate"=>"2015-12-04T17:43:01.000+0000",
            "LastModifiedById"=>"00528000001eP9OAAU",
            "SystemModstamp"=>"2015-12-04T17:43:01.000+0000",
            "LastActivityDate"=>nil,
            "LastViewedDate"=>"2015-12-17T10:20:44.000+0000",
            "LastReferencedDate"=>"2015-12-17T10:20:44.000+0000",
            "Jigsaw"=>nil,
            "JigsawContactId"=>nil,
            "CleanStatus"=>"Pending",
            "CompanyDunsNumber"=>nil,
            "DandbCompanyId"=>nil,
            "EmailBouncedReason"=>nil,
            "EmailBouncedDate"=>nil,
            "SICCode__c"=>"2768",
            "ProductInterest__c"=>"GC5000 series",
            "Primary__c"=>"Yes",
            "CurrentGenerators__c"=>"All",
            "NumberofLocations__c"=>130.0
          }.with_indifferent_access
      }

      let(:output_hash) {
        {
          :id => [{"id"=>"00Q28000003FcanEAC", "provider"=>organization.oauth_provider, "realm"=>organization.oauth_uid}],
          :title=>"Mr",
          :first_name=>"Jeff",
          :last_name=>"Glimpse",
          :is_lead=>true,
          :is_customer=>false,
          :job_title=>"SVP, Procurement",
          :address_work=>
          {
            :billing=>{:country=>"Taiwan, Republic Of China"}
          },
          :email=>{:address=>"jeffg@jackson.com"},
          :phone_work=>{:landline=>"886-2-25474189", :mobile=>"0777-225474189"},
          :lead_source=>"Phone Inquiry",
          :lead_status=>"Open - Not Contacted",
          :lead_conversion_date => DateTime.parse("2016-11-29T15:24:02.000+0000").to_time.iso8601,
        }.with_indifferent_access
      }

      it { expect(subject.map_to('Person', sf_hash)).to eql(output_hash) }
    end
  end
end
