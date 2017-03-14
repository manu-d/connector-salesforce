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

  def get_external_entities(external_entity_name, last_synchronization_date = nil)
    res = super
    @valid_currencies = client.query("select IsoCode from CurrencyType").map{|c| c['IsoCode']} if @fields&.includes?('CurrencyIsoCode')
    res
  end
end

class OpportunityMapper
  extend HashMapper

  after_normalize do |input, output, opts|
    if opts['fields']&.includes?('CurrencyIsoCode')
      unless opts[:valid_currencies].includes?(output[:CurrencyIsoCode])
        output.delete(:CurrencyIsoCode)
        output.delete(:Amount)
      end
    else
      if !opts['organization'].default_currency.blank? && output.delete(:CurrencyIsoCode) != opts['organization'].default_currency 
        output.delete(:Amount)
      end
    end
    output
  end

  after_denormalize do |input, output, opts|
    output[:assignee_type] = 'Entity::AppUser'
    output[:amount].merge!(currency: currency) unless output[:amount].blank? || output[:amount][:currency] || (currency = opts["organization"].default_currency).blank?
    output
  end

  map from('name'), to('Name')
  map from('type'), to('Type')

  map from('description'), to('Description')
  map from('probability'), to('Probability')
  map from('expected_close_date') { |d| d.to_time.iso8601 }, to('CloseDate')
  map from('sales_stage'), to('StageName')
  map from('next_step'), to('NextStep')
  
  map from('amount/total_amount'), to('Amount')
  map from('amount/currency'), to('CurrencyIsoCode')
  
  map from('assignee_id'), to('OwnerId')
end
