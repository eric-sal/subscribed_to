class <%= migration_name.camelize %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name.to_sym %>, :subscribed_to_list, :boolean, :default => false
    <%- if options.service == "mail_chimp" -%>
    add_column :<%= table_name.to_sym %>, :mail_chimp_id, :integer
    add_index :<%= table_name.to_sym %>, :mail_chimp_id
    <%- end -%>
  end

  def self.down
    remove_column :<%= table_name.to_sym %>, :subscribed_to_list
    <%- if options.service == "mail_chimp" -%>
    remove_column :<%= table_name.to_sym %>, :mail_chimp_id, :integer
    remove_index :<%= table_name.to_sym %>, :mail_chimp_id
    <%- end -%>
  end
end
