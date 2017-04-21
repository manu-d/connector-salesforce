class Entities::SubEntities::Product2Mapper
  extend HashMapper

  after_normalize do |input, output|
    output[:ProductCode] ||= input['code']
    output[:IsActive] = input['status'] == 'ACTIVE'
    output
  end

  after_denormalize do |input, output, opts|
    # We set the currency only on creation of the Object
    output[:sale_price] ||= {}
    output[:sale_price][:currency] ||= opts[:organization][:default_currency]

    output[:purchase_price] ||= {}
    output[:purchase_price][:currency] ||= opts[:organization][:default_currency]
    output
  end

  map from('reference'), to('ProductCode')
  map from('description'), to('Description')
  map from('name'), to('Name')
end
