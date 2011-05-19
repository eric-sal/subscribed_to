$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'simplecov'
SimpleCov.start

require 'rspec'
require 'factory_girl'
require 'subscribed_to'

RSpec.configure do |config|
  config.mock_with :mocha
end

ENV['DB'] ||= 'sqlite3'

database_yml = File.expand_path('../database.yml', __FILE__)
if File.exists?(database_yml)
  active_record_configuration = YAML.load_file(database_yml)[ENV['DB']]

  ActiveRecord::Base.establish_connection(active_record_configuration)
  ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "log", "debug.log"))

  ActiveRecord::Base.silence do
    ActiveRecord::Migration.verbose = false

    load('schema.rb')
    Dir["#{File.dirname(__FILE__)}/support/models/*.rb"].each {|f| load f}
    Dir["#{File.dirname(__FILE__)}/support/factories/*.rb"].each {|f| load f}
  end

else
  raise "Please create #{database_yml} first to configure your database. Take a look at: #{database_yml}.sample"
end

Rails.logger = Logger.new(File.join(File.dirname(__FILE__), "log", "debug.log"))

def clean_database!
  models = [User]
  models.each do |model|
    ActiveRecord::Base.connection.execute "DELETE FROM #{model.table_name}"
  end
end

clean_database!
