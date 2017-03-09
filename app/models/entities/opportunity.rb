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

  def push_entity_to_external(mapped_connec_entity_with_idmap, external_entity_name)
    idmap = mapped_connec_entity_with_idmap[:idmap]
    mapped_connec_entity = mapped_connec_entity_with_idmap[:entity]
    id_refs_only_connec_entity = mapped_connec_entity_with_idmap[:id_refs_only_connec_entity]

    begin
      # Create and return id to send to connec!
      if idmap.external_id.blank?
        external_hash = create_external_entity(mapped_connec_entity, external_entity_name)
        idmap.update(external_id: self.class.id_from_external_entity_hash(external_hash), last_push_to_external: Time.now, message: nil)

        return {idmap: idmap, completed_hash: map_and_complete_hash_with_connec_ids(external_hash, external_entity_name, id_refs_only_connec_entity)}
      # Update
      else
        return nil unless self.class.can_update_external?
        external_hash = update_external_entity(mapped_connec_entity, idmap.external_id, external_entity_name)

        completed_hash = map_and_complete_hash_with_connec_ids(external_hash, external_entity_name, id_refs_only_connec_entity)

        # Return the idmap to send it to connec! only if it's the first push of a singleton
        # or if there is a completed hash to send
        if (self.class.singleton? && idmap.last_push_to_external.nil?) || completed_hash
          idmap.update(last_push_to_external: Time.now, message: nil)
          return {idmap: idmap, completed_hash: completed_hash}
        end
        idmap.update(last_push_to_external: Time.now, message: nil)
      end
    rescue => e
      # TODO: improve the flexibility by adding the option for the developer to pass a custom/gem-dependent error
      case e
      when Maestrano::Connector::Rails::Exceptions::EntityNotFoundError
        idmap.update!(message: "The #{external_entity_name} record has been deleted in #{Maestrano::Connector::Rails::External.external_name}. Last attempt to sync on #{Time.now}", external_inactive: true)
        Maestrano::Connector::Rails::ConnectorLogger.log('info', @organization, "The #{idmap.external_entity} - #{idmap.external_id} record has been deleted. It is now set to inactive.")
      else
        # Store External error
        # TODO !! Instead of retrying the call, figure out a way to know if Salesforce
        # company has multi-currency enabled (CurrencyIsoCode exists in that case)
        if e.message && e.message["INVALID_FIELD: No such column 'CurrencyIsoCode'"]
          unless mapped_connec_entity_with_idmap[:entity].delete(:CurrencyIsoCode) == @organization.default_currency
            mapped_connec_entity_with_idmap[:entity].delete(:Amount)
          end
          push_entity_to_external(mapped_connec_entity_with_idmap, external_entity_name)
        elsif e.message && e.message["Opportunity Currency: invalid currency code"]
          mapped_connec_entity_with_idmap[:entity].delete(:CurrencyIsoCode)
          mapped_connec_entity_with_idmap[:entity].delete(:Amount)
          push_entity_to_external(mapped_connec_entity_with_idmap, external_entity_name)
        else
          Maestrano::Connector::Rails::ConnectorLogger.log('error', @organization, "Error while pushing to #{Maestrano::Connector::Rails::External.external_name}: #{e}")
          Maestrano::Connector::Rails::ConnectorLogger.log('debug', @organization, "Error while pushing backtrace: #{e.backtrace.join("\n\t")}")
          idmap.update(message: e.message.truncate(255))
        end
      end
    end

    # Nothing to send to Connec!
    nil
  end
end

class OpportunityMapper
  extend HashMapper

  after_denormalize do |input, output, opts|
    output[:assignee_type] = 'Entity::AppUser'
    output[:amount].merge!(currency: opts["organization"].default_currency) unless output[:amount].blank? || output[:amount][:currency]
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
