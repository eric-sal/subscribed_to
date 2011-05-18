class User < ActiveRecord::Base
  subscribed_to :mailing_list
end

class MailChimpUser < User
  subscribed_to :mailing_list

  attr_accessor :callback_result

  # Stubbed for testing
  def subscribe_to_list
    if subscribed_to_list
      # use hominid to subscribe user
      self.callback_result = "Subscribed"
    else  # mocked for test -- subscribed_to_list normally doesn't do anything if !subscribed_to_list
      self.callback_result = "Not Subscribed"
    end
  end

  # Stubbed for testing
  def update_list_member
    merge_vars = self.class.merge_vars

    if !(self.changed & merge_vars.collect { |key, method| method.to_s }.push("subscribed_to_list")).empty?
      if self.changed.include?("subscribed_to_list")
        if !subscribed_to_list
          # use hominid to unsubscribe user
          self.callback_result = "Unsubscribed"
        else
          # use hominid to subscribe user
          self.callback_result = "Subscribed with: #{merge_vars.each { |key, method| merge_vars[key] = self.send(method.to_sym) }.values.join(", ")}"
        end
      elsif subscribed_to_list && !(self.changed & merge_vars.collect { |key, method| method.to_s }).empty?
        # use hominid to update user
        self.callback_result = "Updated with: #{merge_vars.each { |key, method| merge_vars[key] = self.send(method.to_sym) }.values.join(", ")}"
      end
    else  # mocked for test -- update_list_member normally doesn't do anything in this case
      self.callback_result = "Nothing updated"
    end
  end
end
