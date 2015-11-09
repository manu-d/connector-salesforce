class Entities::Person < Entity

  def connec_entity_name
    "Person"
  end

  def external_entity_name
    "Contact"
  end

  def map_to_external(input)
    PersonMapper.normalize(input)
  end

  def map_to_connec(input)
    PersonMapper.denormalize(input)
  end

  def external_attributes
    %w(
      AccountId
      Salutation
      FirstName
      LastName
      Birthdate
      MailingStreet
      MailingCity
      MailingState
      MailingPostalCode
      MailingCountry
      OtherStreet
      OtherCity
      OtherState
      OtherPostalCode
      OtherCountry
      Email
      Phone
      OtherPhone
      MobilePhone
      Fax
      HomePhone
    )
  end

end

class PersonMapper
  extend HashMapper

  #Not so pretty
  #Case when orga does not exist in connec! or Salesforce ? TODO
  #Should be prettier when connec will handle external id
  before_normalize do |input, output|
    if id = input['organization_id']
      input['organization_id'] = IdMap.find_by_connec_id(id).salesforce_id
    end
    input
  end
  before_denormalize do |input, output|
    if id = input['AccountId']
      input['AccountId'] = IdMap.find_by_salesforce_id(id).connec_id
    end
    input
  end
  map from('/organization_id'), to('/AccountId')

  map from('/title'), to('/Salutation')
  map from('/first_name'), to('/FirstName')
  map from('/last_name'), to('/LastName')
  map from('/Birthdate'), to('/Birthdate')

  map from('address_work/billing/line1'), to('MailingStreet')
  map from('address_work/billing/city'), to('MailingCity')
  map from('address_work/billing/region'), to('MailingState')
  map from('address_work/billing/postal_code'), to('MailingPostalCode')
  map from('address_work/billing/country'), to('MailingCountry')

  map from('address_work/billing2/line1'), to('OtherStreet')
  map from('address_work/billing2/city'), to('OtherCity')
  map from('address_work/billing2/region'), to('OtherState')
  map from('address_work/billing2/postal_code'), to('OtherPostalCode')
  map from('address_work/billing2/country'), to('OtherCountry')

  map from('email/address'), to('Email')

  map from('phone_work/landline'), to('Phone')
  map from('phone_work/landline2'), to('OtherPhone')
  map from('phone_work/mobile'), to('MobilePhone')
  map from('phone_work/fax'), to('Fax')

  map from('phone_home/landline'), to('HomePhone')


#Unmapped salesforce fields

# AssistantName string
# AssistantPhone phone
# MasterRecordId reference
# Owner OwnerId reference
# CreatedById reference
# Department string
# Description textarea
# DoNotCall boolean
# EmailBouncedDate datetime
# EmailBouncedReason string
# HasOptedOutOfEmail boolean
# HasOptedOutOfFax boolean
# IsEmailBounced boolean
# LeadSource picklist
# Salutation picklist
# PhotoUrl url
# ReportsToId reference
# Title string

end

