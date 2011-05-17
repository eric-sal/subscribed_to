require 'subscribed_to/mail_chimp'
require 'active_record'

module SubscribedTo
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
