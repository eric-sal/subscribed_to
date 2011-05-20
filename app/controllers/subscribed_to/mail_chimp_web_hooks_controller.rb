module SubscribedTo
  class MailChimpWebHooksController < ApplicationController

    unloadable

    # Handle MailChimp webhooks
    # Requires a secret key be set in the SubscribedTo initializer.
    # Include the secret key in the post URL for the webhook in your MailChimp account.
    def create
      key = params.delete("key")
      unless key.blank? || key != SubscribedTo.mail_chimp_config.secret_key
        SubscribedTo::MailChimp::WebHook.process(params)
        render :text => nil, :status => 200
      else
        render :text => nil, :status => 404
      end
    end
  end
end
