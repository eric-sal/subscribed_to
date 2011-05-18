require 'spec_helper'

describe "Subscribed To" do
  it "should yield self on setup" do
    SubscribedTo.setup do |config|
      config.should eq SubscribedTo
    end
  end

  it "should configure MailChimp through a block" do
    SubscribedTo.mail_chimp do |config|
      config.should be_an_instance_of SubscribedTo::MailChimp::Config
      config.api_key = "12345"
      config.lists = {:mailing_list => {:id => "abcde", :merge_vars => {"FNAME" => :first_name}}}
    end

    SubscribedTo.mail_chimp_config.api_key.should eq "12345"
    SubscribedTo.mail_chimp_config.lists.should eq :mailing_list => {:id => "abcde", :merge_vars => {"FNAME" => :first_name}}
  end

  it "should add subscribe and update methods to the callback chain" do
    @user = Factory.build(:subscribed_user)
    @user.expects(:subscribe_to_list).once
    @user.save

    @user.first_name = "Edward"
    @user.expects(:update_list_member).once
    @user.save
  end

  context "for MailChimp" do
    it "should include the MailChimp instance methods" do
      User.included_modules.should include SubscribedTo::MailChimp::InstanceMethods
    end
  end
end
