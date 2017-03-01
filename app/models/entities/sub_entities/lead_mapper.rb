class Entities::SubEntities::LeadMapper
  extend HashMapper

  after_normalize do |input, output|
    if input['lead_conversion_date'] && !input['lead_conversion_date'].blank?
      output[:IsConverted] = true
    end
    output[:Status] = input[:lead_status].present? ? input[:lead_status] : 'Open - Not Contacted'
    output
  end

  after_denormalize do |input, output|
    output[:is_lead] = true
    output[:is_customer] = false
    output[:lead_status] = input[:Status]
    output
  end

  map from('title'), to('Salutation')
  map from('first_name'), to('FirstName')
  map from('last_name'), to('LastName'), default: 'Undefined'
  map from('job_title'), to('Title')

  map from('address_work/billing/line1'), to('Street')
  map from('address_work/billing/city'), to('City')
  map from('address_work/billing/region'), to('State')
  map from('address_work/billing/postal_code'), to('PostalCode')
  map from('address_work/billing/country'), to('Country')

  map from('email/address'), to('Email')

  map from('phone_work/landline'), to('Phone')
  map from('phone_work/mobile'), to('MobilePhone')

  map from('lead_source'), to('LeadSource')
  map from('lead_conversion_date') { |d| d.to_time.iso8601 }, to('ConvertedDate')

  map from('description'), to('Description')
end
