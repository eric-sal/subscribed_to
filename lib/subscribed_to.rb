require 'rails'
require 'active_record'
require 'subscribed_to/mail_chimp'

module SubscribedTo
  # Mailing list service to interact with.
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
  #  SubscribedTo.setup do |config|
  #    config.service = :mail_chimp
  #
  #    config.mail_chimp do |mail_chimp_config|
  #      mail_chimp_config.api_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-us1"
  #      mail_chimp_config.lists = {:mailing_list => {:id => "123456", :merge_vars => {"FNAME" => :first_name}
  #    end
  #  end
  def self.mail_chimp(&block)
    @@mail_chimp_config = SubscribedTo::MailChimp::Config.new
    block.call @@mail_chimp_config
  end

  def self.included(base) #nodoc:
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def subscribed_to(id)
      include InstanceMethods
      include MailChimp::InstanceMethods if SubscribedTo.service == :mail_chimp

      @list_key = id.to_sym

      class_eval do
        after_create :subscribe_to_list
        after_update :update_list_member
      end
    end

    def list_id
      SubscribedTo.mail_chimp_config.lists[@list_key][:id]
    end

    def merge_vars
      SubscribedTo.mail_chimp_config.lists[@list_key][:merge_vars]
    end
  end

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
