module SubscribedTo
  module MailChimp
    class Config < Hash  #:nodoc:
      # Creates an accessor that simply sets and reads a key in the hash:
      # Borrowed from Warden: https://github.com/hassox/warden/blob/master/lib/warden/config.rb
      def self.hash_accessor(*names) #:nodoc:
        names.each do |name|
          class_eval <<-METHOD, __FILE__, __LINE__ + 1
            def #{name}
              self[:#{name}]
            end

            def #{name}=(value)
              self[:#{name}] = value
            end
          METHOD
        end
      end

      hash_accessor :active, :api_key, :lists, :secret_key, :enabled_models

      def initialize(config = {})
        merge!(config)
        self[:api_key]        ||= nil
        self[:lists]          ||= {}
        self[:secret_key]     ||= "J/M7k+j8zBJI7SM5"
        self[:enabled_models] ||= {}
      end
    end
  end
end
