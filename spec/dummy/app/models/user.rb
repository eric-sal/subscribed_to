class User < ActiveRecord::Base
  subscribed_to :mailing_list
end
