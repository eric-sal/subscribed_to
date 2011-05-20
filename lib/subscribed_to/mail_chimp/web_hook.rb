module SubscribedTo
  module MailChimp

    # Allows for the usage of MailChimp webhooks.
    # http://apidocs.mailchimp.com/webhooks/
    #
    # To get started:
    #
    # 1) On the list tools page, click the "WebHooks" link.
    #
    # 2) Enter the webhook URL as:
    #   http://mywebapp.com/subscribed_to/mail_chimp?key=<secret_key_defined_in_config>
    #
    # 3) Enable updates for events:
    # * Subscribes
    # * Unsubscribes
    # * Profile Updates
    # * Email Changed
    #
    # 4) Send updates when a change was made by...
    # * A subscriber
    # * Account admin
    # * Via the API
    #
    # 5) Click "Update"
    class WebHook
      LIMIT = 10
      attr_accessor :enabled_models

      # Handles MailChimp webhook request.
      # Takes in a hash of parameters from the webhook.
      #
      # Responds to four webhook events:
      # * +subscribe+
      # * +unsubscribe+
      # * +upemail+
      # * +profile+
      #
      # If a request comes in that does not match one of the four event types, it writes a warning to the default logger
      #
      # TODO: Write to a SubscribedTo specific log instead
      def self.process(params)
        type = params.delete("type").to_sym
        hook = self.new(params)

        hook.respond_to?(type) ?
          hook.send(type.to_sym, params["data"]) :
          Rails.logger.warn("WARNING: MailChimp WebHook does not support the #{type} event.")
      rescue NoMethodError => e
        Rails.logger.warn("WARNING: MailChimp WebHook: #{e.message}")
      end

      # Create a new instance and set some instance variables
      def initialize(params) #:nodoc:
        list_id             = params["data"].delete("list_id")
        self.enabled_models = SubscribedTo.mail_chimp_config.enabled_models[list_id]
      end

      # When a user registers on the site, they are automatically queued for inclusion on the mailing list (if they opt-in).
      #
      # After a user confirms their subscription (MailChimp recommends a double opt-in strategy, but it's not required),
      # a webhook request is sent which includes the "web_id" - a unique ID for mail chimp users. We'll record this id
      # to use with other updates.
      def subscribe(params)
        web_id = params["web_id"]
        email  = params["merges"]["EMAIL"]

        subscriber = nil
        enabled_models.each { |model| subscriber ||= model.constantize.find_by_email(email) }

        subscriber.subscribed_to_list = true
        subscriber.mail_chimp_id = web_id.to_i
        subscriber.save_without_update_list_member(:validate => false)
      end

      # Set the subscribed_to_list attribute to false to prevent any future MailChimp API calls when the user updates
      # their profile in the web app.
      def unsubscribe(params)
        web_id = params["web_id"]

        subscriber = nil
        enabled_models.each { |model| subscriber ||= model.constantize.find_by_mail_chimp_id(web_id) }

        subscriber.subscribed_to_list = false
        subscriber.save_without_update_list_member(:validate => false)
      end

      # If a user updates their email from one of the MailChimp forms (they may get there from a link in an email, or from
      # the confirm subscription page), then a webhook will be sent to the app with the a notice of the changed email.
      # This method will update the web app users's email.
      #
      # Is this a good idea?
      #
      # Theoretically, it seems like the best idea is to keep the web app user and mailing list subscriber email
      # addresses in sync.
      #
      # However, if the web app makes use of login by email, this could create confusion for the user. In this case,
      # it may be best to send an email to the user notifying them that their login information has changed.
      def upemail(params)
        old_email = params["old_email"]
        new_email = params["new_email"]

        subscriber = nil
        enabled_models.each { |model| subscriber ||= model.constantize.find_by_email(old_email) }

        unless over_the_limit(subscriber.updated_at)
          subscriber.email = new_email
          subscriber.save_without_update_list_member(:validate => false)
        end
      end

      # If a user updates any of their subscription information via a MailChimp web form, we need to update that info
      # in the web app.
      #
      # We only update the attributes defined in the SubscribedTo.mail_chimp_config[:lists] merge vars. If more information
      # is sent via the merge vars from MailChimp, but it is not defined in the mail_chimp_config, it is ignored.
      def profile(params)
        web_id = params["web_id"]

        subscriber = nil
        enabled_models.each { |model| subscriber ||= model.constantize.find_by_mail_chimp_id(web_id) }

        unless over_the_limit(subscriber.updated_at)
          subscriber.class.merge_vars.each { |key, method| subscriber.send("#{method.to_s}=", params["merges"][key]) unless params["merges"][key].blank? }
          subscriber.save_without_update_list_member(:validate => false)
        end
      end

      private

      def over_the_limit(updated_at)
        (Time.zone.now - updated_at).seconds <= LIMIT
      end
    end
  end
end
