class AddCurrencyToOrganization < ActiveRecord::Migration
  # We store the currency given by the user from the home page since at the moment,
  # there is no way to get it from Salesforce API 
  def change
  	add_column :organizations, :default_currency, :string
  end
end
