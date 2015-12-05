class SubComplexEntities::Product2Mapper < Maestrano::Connector::Rails::GenericMapper
  extend HashMapper

  map from('code'), to('ProductCode')
  map from('description'), to('Description')
  map from('name'), to('Name')
end