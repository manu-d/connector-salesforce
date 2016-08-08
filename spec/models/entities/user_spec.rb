require 'spec_helper'

describe Entities::User do

  describe 'class methods' do
    subject { Entities::User }

    it { expect(subject.connec_entity_name).to eql('App user') }
    it { expect(subject.external_entity_name).to eql('User') }
    it { expect(subject.object_name_from_connec_entity_hash({'first_name' => 'A', 'last_name' => 'user'})).to eql('A user') }
    it { expect(subject.object_name_from_external_entity_hash({'FirstName' => 'A', 'LastName' => 'user'})).to eql('A user') }
  end

  describe 'instance methods' do
    let(:organization) { create(:organization) }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    subject { Entities::User.new(organization, nil, external_client, {}) }

    describe 'get_external_entities' do
      it 'filters out the system users' do
        allow(external_client).to receive(:describe).and_return({'fields' => []})
        allow(external_client).to receive(:query).and_return([{'Name' => 'Security User'}, {'Name' => 'Bob'}])
        expect(subject.get_external_entities('User')).to eql([{'Name' => 'Bob'}])
      end
    end

    describe 'SalesForce to connec!' do
      let(:sf) {
        {
          "attributes" => {
            "type" => "User",
            "url" => "/services/data/v32.0/sobjects/User/00558000001BYS8AAO"
          },
          "Id" => "00558000001BYS8AAO",
          "Username" => "testsfsb22@yopmail.com",
          "LastName" => "Ppp",
          "FirstName" => "Ppp",
          "Name" => "Ppp Ppp",
          "CompanyName" => "So",
          "Division" => nil,
          "Department" => nil,
          "Title" => nil,
          "Street" => 'First street',
          "City" => 'London',
          "State" => 'Europe',
          "PostalCode" => '232',
          "Country" => "GB",
          "Latitude" => nil,
          "Longitude" => nil,
          "Address" => {
            "city" => 'London',
            "country" => "GB",
            "countryCode" => nil,
            "geocodeAccuracy" => nil,
            "latitude" => nil,
            "longitude" => nil,
            "postalCode" => '232',
            "state" => 'Europe',
            "stateCode" => nil,
            "street" => 'First street'
          },
          "Email" => "testsfsb22@yopmail.com",
          "EmailPreferencesAutoBcc" => true,
          "EmailPreferencesAutoBccStayInTouch" => false,
          "EmailPreferencesStayInTouchReminder" => true,
          "SenderEmail" => nil,
          "SenderName" => nil,
          "Signature" => nil,
          "StayInTouchSubject" => nil,
          "StayInTouchSignature" => nil,
          "StayInTouchNote" => nil,
          "Phone" => nil,
          "Fax" => nil,
          "MobilePhone" => nil,
          "Alias" => "PPpp",
          "CommunityNickname" => "testsfsb22",
          "IsBadged" => false,
          "BadgeText" => "",
          "IsActive" => true,
          "TimeZoneSidKey" => "Europe/London",
          "UserRoleId" => nil,
          "LocaleSidKey" => "en_IE_EURO",
          "ReceivesInfoEmails" => false,
          "ReceivesAdminInfoEmails" => true,
          "EmailEncodingKey" => "ISO-8859-1",
          "ProfileId" => "00e58000000xc5hAAA",
          "UserType" => "Standard",
          "LanguageLocaleKey" => "en_US",
          "EmployeeNumber" => nil,
          "DelegatedApproverId" => nil,
          "ManagerId" => nil,
          "LastLoginDate" => "2016-05-17T15:17:22.000+0000",
          "LastPasswordChangeDate" => "2016-05-17T14:40:46.000+0000",
          "CreatedDate" => "2016-05-17T14:28:05.000+0000",
          "CreatedById" => "00558000001BYS8AAO",
          "LastModifiedDate" => "2016-05-17T14:28:05.000+0000",
          "LastModifiedById" => "00558000001BYS8AAO",
          "SystemModstamp" => "2016-05-17T14:39:53.000+0000",
          "OfflineTrialExpirationDate" => nil,
          "OfflinePdaTrialExpirationDate" => nil,
          "UserPermissionsMarketingUser" => true,
          "UserPermissionsOfflineUser" => true,
          "UserPermissionsCallCenterAutoLogin" => false,
          "UserPermissionsMobileUser" => true,
          "UserPermissionsSFContentUser" => true,
          "UserPermissionsKnowledgeUser" => false,
          "UserPermissionsInteractionUser" => false,
          "UserPermissionsSupportUser" => true,
          "UserPermissionsJigsawProspectingUser" => false,
          "UserPermissionsSiteforceContributorUser" => false,
          "UserPermissionsSiteforcePublisherUser" => false,
          "UserPermissionsChatterAnswersUser" => false,
          "UserPermissionsWorkDotComUserFeature" => false,
          "ForecastEnabled" => true,
          "UserPreferencesActivityRemindersPopup" => true,
          "UserPreferencesEventRemindersCheckboxDefault" => true,
          "UserPreferencesTaskRemindersCheckboxDefault" => true,
          "UserPreferencesReminderSoundOff" => false,
          "UserPreferencesDisableAllFeedsEmail" => false,
          "UserPreferencesDisableFollowersEmail" => false,
          "UserPreferencesDisableProfilePostEmail" => false,
          "UserPreferencesDisableChangeCommentEmail" => false,
          "UserPreferencesDisableLaterCommentEmail" => false,
          "UserPreferencesDisProfPostCommentEmail" => false,
          "UserPreferencesContentNoEmail" => false,
          "UserPreferencesContentEmailAsAndWhen" => false,
          "UserPreferencesApexPagesDeveloperMode" => false,
          "UserPreferencesHideCSNGetChatterMobileTask" => false,
          "UserPreferencesDisableMentionsPostEmail" => false,
          "UserPreferencesDisMentionsCommentEmail" => false,
          "UserPreferencesHideCSNDesktopTask" => false,
          "UserPreferencesHideChatterOnboardingSplash" => false,
          "UserPreferencesHideSecondChatterOnboardingSplash" => false,
          "UserPreferencesDisCommentAfterLikeEmail" => false,
          "UserPreferencesDisableLikeEmail" => false,
          "UserPreferencesDisableMessageEmail" => false,
          "UserPreferencesJigsawListUser" => false,
          "UserPreferencesDisableBookmarkEmail" => false,
          "UserPreferencesDisableSharePostEmail" => false,
          "UserPreferencesEnableAutoSubForFeeds" => false,
          "UserPreferencesDisableFileShareNotificationsForApi" => false,
          "UserPreferencesShowTitleToExternalUsers" => true,
          "UserPreferencesShowManagerToExternalUsers" => false,
          "UserPreferencesShowEmailToExternalUsers" => false,
          "UserPreferencesShowWorkPhoneToExternalUsers" => false,
          "UserPreferencesShowMobilePhoneToExternalUsers" => false,
          "UserPreferencesShowFaxToExternalUsers" => false,
          "UserPreferencesShowStreetAddressToExternalUsers" => false,
          "UserPreferencesShowCityToExternalUsers" => false,
          "UserPreferencesShowStateToExternalUsers" => false,
          "UserPreferencesShowPostalCodeToExternalUsers" => false,
          "UserPreferencesShowCountryToExternalUsers" => false,
          "UserPreferencesShowProfilePicToGuestUsers" => false,
          "UserPreferencesShowTitleToGuestUsers" => false,
          "UserPreferencesShowCityToGuestUsers" => false,
          "UserPreferencesShowStateToGuestUsers" => false,
          "UserPreferencesShowPostalCodeToGuestUsers" => false,
          "UserPreferencesShowCountryToGuestUsers" => false,
          "UserPreferencesDisableFeedbackEmail" => false,
          "UserPreferencesDisableWorkEmail" => false,
          "UserPreferencesHideS1BrowserUI" => false,
          "UserPreferencesDisableEndorsementEmail" => false,
          "UserPreferencesLightningExperiencePreferred" => false,
          "ContactId" => nil,
          "AccountId" => nil,
          "CallCenterId" => nil,
          "Extension" => nil,
          "FederationIdentifier" => nil,
          "AboutMe" => nil,
          "FullPhotoUrl" => "https://c.eu6.content.force.com/profilephoto/005/F",
          "SmallPhotoUrl" => "https://c.eu6.content.force.com/profilephoto/005/T",
          "DigestFrequency" => "D",
          "DefaultGroupNotificationFrequency" => "N",
          "JigsawImportLimitOverride" => nil,
          "LastViewedDate" => nil,
          "LastReferencedDate" => nil
        }
      }

      let (:mapped_sf) {
        {
          "first_name" => "Ppp",
          "last_name" => "Ppp",
          "address_work" => {
            "billing" => {
              "line1" => "First street",
              "city" => "London",
              "region" => "Europe",
              "postal_code" => "232",
              "country" => "GB"
            }
          },
          "email" => {
            "address" => "testsfsb22@yopmail.com"
          },
          "id" => [
            {
              "id" => "00558000001BYS8AAO",
              "provider" => "this_app",
              "realm" => "sfuiy765"
            }
          ]
        }.with_indifferent_access
      }

      it { expect(subject.map_to_connec(sf)).to eql(mapped_sf) }
    end

    describe 'connec to salesforce' do
      let(:connec) {
        {
          "id" => "ae38bc11-b6d0-0133-f5b8-067594f4f433",
          "code" => "US3",
          "first_name" => "John",
          "last_name" => "Doe",
          "email" => {
            "address" => "jane.doe@maestrano.com",
            "address2" => ""
          },
          "address_work" => {
            "billing" => {
              "line1" => "line1",
              "city" => "here",
              "region" => "ab",
              "postal_code" => "123",
              "country" => "France"
            },
            "billing2" => {},
            "shipping" => {},
            "shipping2" => {}
          },
          "address_home" => {
            "billing" => {},
            "billing2" => {},
            "shipping" => {},
            "shipping2" => {}
          },
          "phone_work" => {
            "landline" => "123",
            "landline2" => "123",
            "mobile" => "123",
            "fax" => "123"
          },
          "phone_home" => {
            "landline" => ""
          },
          "teams" => [],
          "channel_id" => "org-fgsh",
          "resource_type" => "app_users"
        }
      }

      let(:mapped_connec) {
        {
          "FirstName" => "John",
          "LastName" => "Doe",
          "Street" => "line1",
          "City" => "here",
          "State" => "ab",
          "PostalCode" => "123",
          "Country" => "France",
          "Email" => "jane.doe@maestrano.com",
          "Phone" => "123",
          "MobilePhone" => "123",
          "Fax" => "123"
        }.with_indifferent_access
      }

      it { expect(subject.map_to_external(connec)).to eql(mapped_connec) }
    end
  end
end
