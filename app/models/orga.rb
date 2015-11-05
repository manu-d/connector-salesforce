class Orga < Entity

  def connec_entity_name
    "Organization"
  end

  def external_entity_name
    "Account"
  end

  def mapping
    {
      name: "Name",
      industry: "Industry"
    }
  end

end