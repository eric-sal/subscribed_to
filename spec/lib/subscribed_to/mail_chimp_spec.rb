require 'spec_helper'
require 'hominid'

describe SubscribedTo::MailChimp do
  before(:each) do
    SubscribedTo.mail_chimp do |config|
      config.api_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-us1"
      config.lists = {:mailing_list => {:id => "123456", :merge_vars => {"FNAME" => :first_name, "LNAME" => :last_name, "EMAIL" => :email}}}
    end

    @h = mock("hominid")
    Hominid::API.stubs(:new).returns(@h)
  end

  context "for a new user" do
    it "should subscribe the user if subscribed_to_list is true" do
      @h.expects(:list_subscribe).once
      Factory(:subscribed_user)
    end

    it "should not subscribe the user if subscribed_to_list is false" do
      @h.expects(:list_subscribe).never
      Factory(:non_subscribed_user)
    end

    it "should rescue and log Hominid::APIErrors" do
      @h.expects(:list_subscribe).raises(Hominid::APIError, mock("FaultException", :faultCode => "xxx", :message => "api error"))
      Rails.logger.expects(:warn).once
      Factory(:subscribed_user)
    end
  end

  context "for an existing user" do
    context "who is not subscribed to the mailing list" do
      before { @user = Factory(:non_subscribed_user) }

      it "should subscribe the user" do
        @h.expects(:list_subscribe).once
        @user.update_attributes({:subscribed_to_list => true})
      end
    end

    context "who is subscribed to the mailing list" do
      before do
        @user = Factory.build(:subscribed_user)
        @user.stubs(:subscribe_to_list)
        @user.save
      end

      it "should unsubscribe the user" do
        @h.expects(:list_unsubscribe).once
        @user.update_attributes({:subscribed_to_list => false})
      end

      it "should update list member attributes for the user" do
        @h.expects(:list_update_member).once
        @user.update_attributes({:first_name => "Ed", :last_name => "Salczynski", :email => "ed@whtt.me"})
      end

      it "should not update list member when attributes not defined in merge vars are changed" do
        @h.expects(:list_subscribe).never
        @h.expects(:list_unsubscribe).never
        @h.expects(:list_update_member).never
        @user.update_attributes({:password => "zyx321"})
      end

      it "should rescue and log Hominid::APIErrors" do
        @h.expects(:list_unsubscribe).raises(Hominid::APIError, mock("FaultException", :faultCode => "xxx", :message => "api error"))
        Rails.logger.expects(:warn).once
        @user.update_attributes({:subscribed_to_list => false})
      end
    end
  end
end
