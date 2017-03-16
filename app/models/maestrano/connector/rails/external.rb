class Maestrano::Connector::Rails::External
  include Maestrano::Connector::Rails::Concerns::External

  # Return an array of all the entities that the connector can synchronize
  # If you add new entities, you need to generate
  # a migration to add them to existing organizations
  def self.entities_list
    %w(organization contact_and_lead item user opportunity)
  end

  def self.external_name
    'SalesForce'
  end

  def self.create_account_link(organization = nil)
    'https://www.salesforce.com/au/form/signup/freetrial-sales-ee.jsp?d=70130000000F6Dc'
  end

  def self.get_client(organization)
    @@client = Restforce.new :oauth_token => organization.oauth_token,
      refresh_token: organization.refresh_token,
      instance_url: organization.instance_url,
      client_id: ENV['salesforce_client_id'],
      client_secret: ENV['salesforce_client_secret']
  end

  # Fetch the user profile
  # {
  #   "id"=>"https://login.salesforce.com/id/00D28000000sjmoEAA/00528000002SnXuAAK",
  #   "asserted_user"=>true,
  #   "user_id"=>"00528000002SnXuAAK",
  #   "organization_id"=>"00D28000000sjmoEAA",
  #   "username"=>"bruno.chauvet+sf1@maestrano.com",
  #   "nick_name"=>"bruno.chauvet+sf11.4546470421145972E12",
  #   "display_name"=>"Bruno Chauvet",
  #   "email"=>"bruno.chauvet+sf1@maestrano.com",
  #   "email_verified"=>true,
  #   "first_name"=>"Bruno",
  #   "last_name"=>"Chauvet",
  #   "timezone"=>"Australia/Sydney",
  #   "photos"=>{
  #     "picture"=>"https://c.ap2.content.force.com/profilephoto/005/F",
  #     "thumbnail"=>"https://c.ap2.content.force.com/profilephoto/005/T"
  #   },
  #   "addr_street"=>nil,
  #   "addr_city"=>nil,
  #   "addr_state"=>nil,
  #   "addr_country"=>"AU",
  #   "addr_zip"=>nil,
  #   "mobile_phone"=>nil,
  #   "mobile_phone_verified"=>false,
  #   "status"=>{
  #     "created_date"=>nil,
  #     "body"=>nil
  #   },
  #   "active"=>true,
  #   "user_type"=>"STANDARD",
  #   "language"=>"en_US",
  #   "locale"=>"en_AU",
  #   "utcOffset"=>36000000,
  #   "last_modified_date"=>"2016-02-05T04:37:19.000+0000"
  # }
  def self.fetch_user(organization, client = nil)
    client = Maestrano::Connector::Rails::External.get_client(organization) unless client
    response = client.authenticate!
    client.get(response.id).body
  end

  # Fetch the company details
  # {"attributes"=>{"type"=>"Organization", "url"=>"/services/data/v32.0/sobjects/Organization/00D28000000sjmoEAA"}, "Id"=>"00D28000000sjmoEAA", "Name"=>"Maestrano"}
  def self.fetch_company(organization)
    client = Maestrano::Connector::Rails::External.get_client(organization)
    client.query('SELECT id, Name from Organization LIMIT 1')[0]
  end

  def self.timezone
    @@timezone ||= user_timezone
  end

  def self.user_timezone
    Maestrano::Connector::Rails::External.fetch_user(nil, @@client)['timezone']
  rescue => e
    nil
  end

  def self.valid_currencies
    @@valid_currencies ||= account_currencies
  end

  def self.account_currencies
    @@client.query("select IsoCode from CurrencyType").map{|c| c['IsoCode']}
  rescue => e
    []
  end
end
