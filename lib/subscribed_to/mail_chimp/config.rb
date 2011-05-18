module SubscribedTo
  module MailChimp
    class Config < Hash
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

      hash_accessor :api_key, :lists

      def initialize(config = {})
        merge!(config)
        self[:api_key] ||= nil
        self[:lists]   ||= {}
      end
    end
  end
end
