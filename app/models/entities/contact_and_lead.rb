class Entities::ContactAndLead < Maestrano::Connector::Rails::ComplexEntity
  def self.connec_entities_names
    %w(Person)
  end

  def self.external_entities_names
    %w(Contact Lead)
  end

  # input :  {
  #             connec_entity_names[0]: [unmapped_connec_entitiy1, unmapped_connec_entitiy2],
  #             connec_entity_names[1]: [unmapped_connec_entitiy3, unmapped_connec_entitiy4]
  #          }
  # output : {
  #             connec_entity_names[0]: {
  #               external_entities_names[0]: [unmapped_connec_entitiy1, unmapped_connec_entitiy2]
  #             },
  #             connec_entity_names[1]: {
  #               external_entities_names[0]: [unmapped_connec_entitiy3],
  #               external_entities_names[1]: [unmapped_connec_entitiy4]
  #             }
  #          }
  def connec_model_to_external_model(connec_hash_of_entities)
    people = connec_hash_of_entities['Person']
    modeled_hash = { 'Person' => { 'Lead' => [], 'Contact' => [] } }

    people.each do |person|
      if person['is_lead']
        modeled_hash['Person']['Lead'] << person
      else
        modeled_hash['Person']['Contact'] << person
      end
    end
    modeled_hash
  end

  # input :  {
  #             external_entities_names[0]: [unmapped_external_entity1, unmapped_external_entity2],
  #             external_entities_names[1]: [unmapped_external_entity3, unmapped_external_entity4]
  #          }
  # output : {
  #             external_entities_names[0]: {
  #               connec_entity_names[0]: [unmapped_external_entity1],
  #               connec_entity_names[1]: [unmapped_external_entity2]
  #             },
  #             external_entities_names[1]: {
  #               connec_entity_names[0]: [unmapped_external_entity3, unmapped_external_entity4]
  #             }
  #           }
  def external_model_to_connec_model(external_hash_of_entities)
    {'Lead' => { 'Person' => external_hash_of_entities['Lead'] }, 'Contact' => { 'Person' => external_hash_of_entities['Contact'] }}
  end
end
