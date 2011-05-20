require 'subscribed_to/mail_chimp/config'
require 'hominid'

module SubscribedTo
  # Module for MailChimp subscription interaction
  module MailChimp
    module InstanceMethods
      private

      # Subscribe the user to the mailing list
      def subscribe_to_list  #:doc:
        merge_vars = self.class.merge_vars.dup

        if subscribed_to_list
          h = Hominid::API.new(SubscribedTo.mail_chimp_config.api_key)
          h.list_subscribe(self.class.list_id, self.email, merge_vars.each { |key, method| merge_vars[key] = (self.send(method.to_sym) || "") })
        end
      rescue Hominid::APIError => e
        Rails.logger.warn e
      end

      # Update attributes of existing member
      def update_list_member  #:doc:
        config     = SubscribedTo.mail_chimp_config
        merge_vars = self.class.merge_vars.dup

        # only do the update if either the subscription preference has changed (the user wants to be (un)subscribed),
        # or if one of the attributes in mail_chimp_config.merge_vars has changed
        if !(self.changed & merge_vars.collect { |key, method| method.to_s }.push("subscribed_to_list")).empty?
          api_key          = config.api_key
          list_id          = self.class.list_id
          email_attr       = merge_vars["EMAIL"]
          subscribed_email = self.changed.include?(email_attr.to_s) ? changed_attributes[email_attr.to_s] : self.send(email_attr)
          h                = Hominid::API.new(api_key)

          if self.changed.include?("subscribed_to_list")
            if !subscribed_to_list
              h.list_unsubscribe(list_id, subscribed_email)
            else
              h.list_subscribe(list_id, subscribed_email, merge_vars.each { |key, method| merge_vars[key] = self.send(method.to_sym) })
            end
          elsif subscribed_to_list && !(self.changed & merge_vars.collect { |key, method| method.to_s }).empty?
            h.list_update_member(list_id, subscribed_email, merge_vars.each { |key, method| merge_vars[key] = self.send(method.to_sym) })
          end
        end
      rescue Hominid::APIError => e
        Rails.logger.warn e
      end
    end
  end
end
