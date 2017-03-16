class Entities::SubEntities::PricebookEntryMapper
  extend HashMapper

  after_normalize do |input, output, opts|
  	valid_currencies = Maestrano::Connector::Rails::External.valid_currencies
    unless valid_currencies&.include?(output[:CurrencyIsoCode])
      currency = opts[:organization]&.default_currency
      unless currency.blank? || currency == output.delete(:CurrencyIsoCode)
        output[:UnitPrice] = "0.0"
        idmap = input['idmap']
        idmap.update_attributes(metadata: idmap.metadata.merge(ignore_currency_update: true)) if idmap
      end
    end
    output
  end

  after_denormalize do |input, output, opts|
    output[:sale_price].merge!(currency: opts[:organization].default_currency) unless output[:sale_price].blank? || output[:sale_price][:currency] || opts[:organization].default_currency.blank?
    output
  end

  map from('sale_price/net_amount'), to('UnitPrice')
  map from('sale_price/currency'), to('CurrencyIsoCode')
end