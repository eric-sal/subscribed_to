Factory.define :subscribed_user, :class => User do |u|
  u.first_name          "Eric"
  u.last_name           "Salczynski"
  u.email               "eric@wehaventthetime.com"
  u.subscribed_to_list  true
  u.mail_chimp_id       "123"
  u.password            "abc123"
end

Factory.define :non_subscribed_user, :class => User do |u|
  u.first_name          "Ashley"
  u.last_name           "Beasy"
  u.email               "ashley@wehaventthetime.com"
  u.subscribed_to_list  false
  u.password            "abc123"
end
