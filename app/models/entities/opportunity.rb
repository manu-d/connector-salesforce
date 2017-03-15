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

  def push_entities_to_connec_to(mapped_external_entities_with_idmaps, connec_entity_name)
    return unless @organization.push_to_connec_enabled?(self)

    Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "Sending #{Maestrano::Connector::Rails::External.external_name} #{self.class.external_entity_name.pluralize} to Connec! #{connec_entity_name.pluralize}")

    # Existing connec entities will contain all the hashes from Connec that need to be updated
    connec_existing_ids = mapped_external_entities_with_idmaps.map { |mapped_external_entity_with_idmap| mapped_external_entity_with_idmap[:idmap].connec_id }.compact
    proc = ->(connec_existing_id) { batch_get(connec_existing_id) }
    existing_connec_entities = batch_get_call(connec_existing_ids, proc)

    mapped_external_entities_with_idmaps.each do |mapped_external_entity_with_idmap|
      id = mapped_external_entity_with_idmap[:idmap].connec_id
      next unless id
      # For updates, we remove the price as we don't want to update it if the currencies don't match
      entity = mapped_external_entity_with_idmap[:entity]
      entity.delete('amount') unless (currency = entity.dig('amount', 'currency')).blank? || currency == get_currency(existing_connec_entities, id)
    end

    proc = ->(mapped_external_entity_with_idmap) { batch_op('post', mapped_external_entity_with_idmap[:entity], nil, self.class.normalize_connec_entity_name(connec_entity_name)) }
    batch_calls(mapped_external_entities_with_idmaps, proc, connec_entity_name)
  end

  def batch_get(id)
    {
      method: 'get',
      url: "/api/v2/#{@organization.uid}/opportunities/#{id}",
    }
  end

  def batch_get_call(ids, proc)
    request_per_call = @opts[:request_per_batch_call] || 100
    start = 0
    results = []
    while start < ids.size
      # Prepare batch request
      batch_entities = ids.slice(start, request_per_call)
      batch_request = {sequential: true, ops: []}
      batch_entities.each do |id|
        batch_request[:ops] << proc.call(id)
      end

      # Batch call
      response = @connec_client.batch(batch_request)
      response = JSON.parse(response.body)
      # Parse batch response
      response['results'].each do |result|
        results << result.dig('body', 'opportunities')
      end

      start += request_per_call
    end
    results.compact
  end

  def get_currency(connec_hashes, id)
    connec_hashes.each do |connec_hash|
      return connec_hash.dig('amount', 'currency') if connec_hash['id'].select { |id| id['provider'] == 'connec' }.first['id'] == id
    end
    nil
  end

  def get_external_entities(external_entity_name, last_synchronization_date = nil)
    @valid_currencies = @external_client.query("select IsoCode from CurrencyType").map{|c| c['IsoCode']}
    @timezone = Maestrano::Connector::Rails::External.fetch_user(@organization, @external_client)['timezone']
    super
  rescue Faraday::ClientError => e
    @valid_currencies = []
    super
  end
end

class OpportunityMapper
  extend HashMapper

  after_normalize do |input, output, opts|
    unless opts['valid_currencies']&.include?(output[:CurrencyIsoCode])
      output.delete(:Amount) unless (currency = opts["organization"]&.default_currency).blank? || currency == output.delete(:CurrencyIsoCode)
    end
    output[:CloseDate] = ActiveSupport::TimeZone[opts['timezone']].parse(output[:CloseDate]).strftime('%F') if opts['timezone']
    output
  end

  after_denormalize do |input, output, opts|
    output[:assignee_type] = 'Entity::AppUser'
    output[:amount].merge!(currency: currency) unless output[:amount].blank? || output[:amount][:currency] || (currency = opts["organization"].default_currency).blank?
    output[:expected_close_date] = ActiveSupport::TimeZone[opts['timezone']].parse(output[:expected_close_date]+' 23:59:59').utc.strftime('%FT%TZ') if opts['timezone']
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
