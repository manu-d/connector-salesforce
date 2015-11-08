class Orga < Entity

  def connec_entity_name
    "Organization"
  end

  def external_entity_name
    "Account"
  end

  def map_to_external(input)
    OrgaMapper.normalize(input)
  end

  def map_to_connec(input)
    OrgaMapper.denormalize(input)
  end

  def external_attributes
    [
      "Name",
      "Industry"
    ]
  end

end

class OrgaMapper
  extend HashMapper

  map from('/name'),  to('/Name')
  map from('/industry'),  to('/Industry')
end