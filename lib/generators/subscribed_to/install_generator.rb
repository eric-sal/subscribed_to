module SubscribedTo
  module Generators
    class InstallGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      desc "Create SubscribedTo initializer and migration. Pass the name of the model to hook up with SubscribedTo."
      class_option :migration, :type => :boolean, :default => true, :desc => "Include migration for required columns"
      class_option :service, :type => :string, :default => "mail_chimp", :desc => "Mailing list service to connect to [mail_chimp, constant_contact]"

      def self.next_migration_number(dirname)
        Time.now.strftime("%Y%m%d%H%M%S")
      end

      def copy_initializer
        template "subscribed_to.rb", "config/initializers/subscribed_to.rb"
      end

      def copy_migration
        migration_template "migration.rb", "db/migrate/#{migration_name}" if options.migration?
      end

      private

      def migration_name
        "add_subscribed_to_list_to_#{table_name}"
      end

      def table_name
        name.tableize
      end
    end
  end
end
