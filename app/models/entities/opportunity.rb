class Entities::Opportunity < Maestrano::Connector::Rails::Entity

  def self.connec_entity_name
    'Opportunity'
  end

  def self.external_entity_name
    'Opportunity'
  end

  def self.mapper_class
    OpportunityMapper
  end

  def self.references
    %w(assignee_id)
  end

  def self.object_name_from_connec_entity_hash(entity)
    entity['name']
  end

  def self.object_name_from_external_entity_hash(entity)
    entity['Name']
  end

  def self.currency_check_field
    'amount'
  end
end

class OpportunityMapper
  extend HashMapper

  after_normalize do |input, output, opts|
    valid_currencies = Maestrano::Connector::Rails::External.valid_currencies
    unless valid_currencies&.include?(output[:CurrencyIsoCode])
      currency = opts[:organization]&.default_currency
      unless currency.blank? || currency == output.delete(:CurrencyIsoCode)
        output.delete(:Amount)
        idmap = input['idmap']
        idmap.update_attributes(metadata: idmap.metadata.merge(ignore_currency_update: true)) if idmap
      end
    end
    timezone = Maestrano::Connector::Rails::External.timezone
    output[:CloseDate] = ActiveSupport::TimeZone[timezone].parse(output[:CloseDate]).strftime('%F') if timezone
    output
  end

  after_denormalize do |input, output, opts|
    output[:assignee_type] = 'Entity::AppUser'
    output[:amount].merge!(currency: opts[:organization].default_currency) unless output[:amount].blank? || output[:amount][:currency] || opts[:organization].default_currency.blank?
    timezone = Maestrano::Connector::Rails::External.timezone
    output[:expected_close_date] = ActiveSupport::TimeZone[timezone].parse(input['CloseDate'] + ' 23:59:59').utc.strftime('%FT%TZ') if timezone && input['CloseDate']
    output
  end

  map from('name'), to('Name')
  map from('type'), to('Type')

  map from('description'), to('Description')
  map from('probability'), to('Probability')
  map from('expected_close_date'), to('CloseDate')
  map from('sales_stage'), to('StageName')
  map from('next_step'), to('NextStep')
  
  map from('amount/total_amount'), to('Amount')
  map from('amount/currency'), to('CurrencyIsoCode')
  
  map from('assignee_id'), to('OwnerId')
end
