SubscribedTo.setup do |config|
  config.service = :mail_chimp

  config.mail_chimp do |mail_chimp_config|
    # Your MailChimp API key.
    mail_chimp_config.api_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-us1"

    # A hash of mailing lists to subscribe users to.
    # List names can be any valid symbol.
    #
    # Required:
    #   :id - id of list
    #   :merge_vars - hash of merge vars on list, MUST at least include "EMAIL" (do not use "MERGE0")
    mail_chimp_config.lists = {
      :mailing_list => {
        :id => "xxxxxxxx",
        :merge_vars => {"FNAME" => :first_name, "LNAME" => :last_name, "EMAIL" => :email}}}

    mail_chimp_config.secret_key = "J/M7k+j8zBJI7SM5"
  end
end
