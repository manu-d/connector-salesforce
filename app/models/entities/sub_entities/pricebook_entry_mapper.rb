class Entities::SubEntities::PricebookEntryMapper
  extend HashMapper

  map from('sale_price/net_amount'), to('UnitPrice')
end