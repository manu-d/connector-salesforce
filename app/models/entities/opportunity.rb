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

  def self.external_attributes
    %w(
      Amount
      CloseDate
      Description
      NextStep
      Name
      Probability
      StageName
      Type
    )
    #StageName and CloseDate are mandatory for SF
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

  before_denormalize do |input, output|
    if input['CloseDate']
      input['CloseDate'] = input['CloseDate'].to_time.iso8601
    end
    input
  end

  map from('amount/total_amount'), to('Amount')
  map from('expected_close_date'), to('CloseDate')
  map from('description'), to('Description')
  map from('next_step'), to('NextStep')
  map from('name'), to('Name')
  map from('probability'), to('Probability')
  map from('sales_stage'), to('StageName')
  map from('type'), to('Type')
end

