$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'database_cleaner'
require 'factory_girl'

# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each {|f| load f}

RSpec.configure do |config|
  config.mock_with :mocha

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end


# Time warp functionality from https://github.com/harvesthq/time-warp
# Extend the Time class so that we can offset the time that 'now'
# returns.  This should allow us to effectively time warp for functional
# tests that require limits per hour, what not.
if !Time.respond_to?(:real_now)  # assures there is no infinite looping when aliasing #now
  Time.class_eval do
    class << self
      attr_accessor :testing_offset

      alias_method :real_now, :now
      def now
        real_now - testing_offset
      end
      alias_method :new, :now

    end
  end
end
Time.testing_offset = 0

def pretend_now_is(*args)
  Time.testing_offset = Time.now - time_from(*args)
  if block_given?
    begin
      yield
    ensure
      reset_to_real_time
    end
  end
end

##
# Reset to real time.
def reset_to_real_time
  Time.testing_offset = 0
end

def time_from(*args)
  return args[0] if 1 == args.size && args[0].is_a?(Time)
  return args[0].to_time if 1 == args.size && args[0].respond_to?(:to_time)  # For example, if it's a Date.
  Time.utc(*args)
end
