require "spec_helper"
require "action_controller"
require "generator_spec/test_case"
require 'generators/subscribed_to/install_generator'

describe SubscribedTo::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../tmp", __FILE__)

  before(:all) { prepare_destination }

  context "when run with default options" do
    before(:all) { run_generator %w(User) }

    it "should create an initializer" do
      assert_file "config/initializers/subscribed_to.rb", /config.service = :mail_chimp/
    end

    it "should create a migration" do
      assert_file "db/migrate/#{SubscribedTo::Generators::InstallGenerator.next_migration_number("")}_add_subscribed_to_list_to_users.rb"
    end
  end

  context "when run with --skip-migration" do
    before(:all) do
      prepare_destination
      run_generator %w(User --skip-migration)
    end

    it "should not create a migration" do
      assert_no_file "db/migrate/#{SubscribedTo::Generators::InstallGenerator.next_migration_number("")}_add_subscribed_to_list_to_users.rb"
    end
  end
end
