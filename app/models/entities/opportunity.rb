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
end

class OpportunityMapper
  extend HashMapper

  after_denormalize do |input, output|
    output[:assignee_type] = 'Entity::AppUser'
    output
  end

  map from('amount/total_amount'), to('Amount')
  map from('expected_close_date'){|d| d.to_time.iso8601}, to('CloseDate')
  map from('description'), to('Description')
  map from('next_step'), to('NextStep')
  map from('name'), to('Name')
  map from('probability'), to('Probability')
  map from('sales_stage'), to('StageName')
  map from('type'), to('Type')
  map from('assignee_id'), to('OwnerId')

end

