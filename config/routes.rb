Rails.application.routes.draw do
  namespace :subscribed_to do
    match "mail_chimp" => "mail_chimp_web_hooks#create", :via => :post
  end
end
