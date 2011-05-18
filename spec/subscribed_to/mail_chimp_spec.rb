require 'spec_helper'
require 'hominid'

describe SubscribedTo::MailChimp do
  before(:each) do
    SubscribedTo.mail_chimp do |config|
      config.api_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-us1"
      config.lists = {:mailing_list => {:id => "123456", :merge_vars => {"FNAME" => :first_name, "LNAME" => :last_name, "EMAIL" => :email}}}
    end
  end

  context "for a new user" do
    it "should subscribe the user" do
      @user = MailChimpUser.create(Factory.attributes_for(:subscribed_user))
      @user.callback_result.should eq "Subscribed with: Eric, Salczynski, eric@wehaventthetime.com"
    end

    it "should not subscribe the user" do
      @user = MailChimpUser.create(Factory.attributes_for(:non_subscribed_user))
      @user.callback_result.should eq "Not Subscribed"
    end
  end

  context "for an existing user" do
    context "who is not subscribed to the mailing list" do
      before { @user = MailChimpUser.create(Factory.attributes_for(:non_subscribed_user)) }

      it "should subscribe the user" do
        @user.update_attributes({:subscribed_to_list => true})
        @user.callback_result.should eq "Subscribed with: #{[@user.first_name, @user.last_name, @user.email].join(", ")}"
      end
    end

    context "who is subscribed to the mailing list" do
      before(:each) { @user = MailChimpUser.create(Factory.attributes_for(:subscribed_user)) }

      it "should unsubscribe the user" do
        @user.update_attributes({:subscribed_to_list => false})
        @user.callback_result.should eq "Unsubscribed"
      end

      it "should update list member attributes for the user" do
        @user.update_attributes({:first_name => "Ed", :last_name => "Salczynski", :email => "ed@whtt.me"})
        @user.callback_result.should eq "Updated with: Ed, Salczynski, ed@whtt.me"
      end

      it "should not update list member when attributes not defined in merge vars are changed" do
        @user.update_attributes({:password => "zyx321"})
        @user.callback_result.should eq "Nothing updated"
      end
    end
  end
end
