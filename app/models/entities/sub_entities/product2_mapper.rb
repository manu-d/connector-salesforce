class Entities::SubEntities::Product2Mapper
  extend HashMapper

  after_normalize do |input, output|
    output[:ProductCode] ||= input['code']
    output
  end

  map from('reference'), to('ProductCode')
  map from('description'), to('Description')
  map from('name'), to('Name')
end