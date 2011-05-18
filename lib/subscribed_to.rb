require 'rails'
require 'active_record'
require 'subscribed_to/mail_chimp'

module SubscribedTo
  # Mailing list service to interact with.
  # Options: :mail_chimp, :constant_contact
  # Currently only supports Mail Chimp
  mattr_accessor :service
  @@service = :mail_chimp

  mattr_accessor :mail_chimp_config
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
  #      mail_chimp_config.api_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxx-us1"
  #      mail_chimp_config.lists = {:mailing_list => {:id => "12345", :merge_vars => {"FNAME" => :first_name}
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
    def subscribed_to(id, options)
      include SubscribedTo::MailChimp::InstanceMethods

      class_eval do
        after_create :subscribe_to_list
        after_update :update_list_member
      end
    end

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
