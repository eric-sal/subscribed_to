module ActiveRecord #:nodoc:
  module Persistence
    # We need to skip the after_update callback here. Otherwise, we'll trigger a loop of MailChimp updates.
    def save_without_update_list_member(options)
      self.class.skip_callback(:update, :after, :update_list_member)
      self.save(options)
      self.class.set_callback(:update, :after, :update_list_member)
    end
  end
end
