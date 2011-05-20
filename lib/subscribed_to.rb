require 'rails'
require 'active_record'
require 'active_record_extensions'
require 'subscribed_to/mail_chimp'

module SubscribedTo
  # Activate the gem.
  #
  # Can be disabled for development, staging, etc environtments.
  # Activated only in production environment by default.
  mattr_accessor :active
  @@active = Rails.env == "production"

  # Mailing list service to interact with.
  #
  # Options: :mail_chimp, :constant_contact
  # Currently only supports Mail Chimp
  mattr_accessor :service
  @@service = :mail_chimp

  mattr_reader :mail_chimp_config
  @@mail_chimp_config = nil

  # Set up SubscribedTo
  def self.setup
    yield self
  end

  # Sets Mail Chimp configuration using a block
  #
  # Example configuration:
  #   SubscribedTo.setup do |config|
  #     config.service = :mail_chimp
  #
  #     config.mail_chimp do |mail_chimp_config|
  #       mail_chimp_config.api_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-us1"
  #       mail_chimp_config.lists = {:mailing_list => {:id => "123456", :merge_vars => {"FNAME" => :first_name}
  #       mail_chimp_config.secret_key = "abc123"
  #     end
  #   end
  def self.mail_chimp(&block)
    @@mail_chimp_config = SubscribedTo::MailChimp::Config.new
    block.call @@mail_chimp_config
  end

  def self.included(base) #:nodoc:
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # Enable *SubscribedTo* in your user model.
    # The only paramter it takes is a symbol which corresponds to a list in the <tt>mail_chimp_config.lists</tt> hash.
    #   subscribed_to :mailing_list
    def subscribed_to(id)
      if SubscribedTo.active  # don't activate all the gem goodies if we're not active
        include InstanceMethods
        if SubscribedTo.service == :mail_chimp
          extend MailChimp::ClassMethods
          include MailChimp::InstanceMethods
        end

        @list_key = id.to_sym

        # We need to reference which models are enabled, and which list they belong to when processing the webhooks.
        SubscribedTo.mail_chimp_config.enabled_models[self.list_id].blank? ?
          SubscribedTo.mail_chimp_config.enabled_models[self.list_id] = [self.to_s] :
          SubscribedTo.mail_chimp_config.enabled_models[self.list_id] << self.to_s

        class_eval do
          after_create :subscribe_to_list
          after_update :update_list_member
        end
      end
    end
  end

  # Provides instance methods which should be overwritten in service modules
  module InstanceMethods
    private

    # Override in MailChimp module
    def subscribe_to_list
    end

    # Override in MailChimp module
    def update_list_member
    end
  end
end

ActiveRecord::Base.send :include, SubscribedTo

require 'subscribed_to/engine'
