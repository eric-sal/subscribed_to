class <%= migration_name.camelize %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name.to_sym %>, :subscribed_to_list, :boolean, :default => false
  end

  def self.down
    remove_column :<%= table_name.to_sym %>, :subscribed_to_list
  end
end
