require 'spec_helper'

describe SubscribedTo do
  it "should yield self on setup" do
    SubscribedTo.setup do |config|
      config.should eq SubscribedTo
    end
  end

  it "should configure MailChimp through a block" do
    SubscribedTo.mail_chimp do |config|
      config.should be_an_instance_of SubscribedTo::MailChimp::Config
      config.api_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-us1"
      config.lists = {:mailing_list => {:id => "123456", :merge_vars => {"FNAME" => :first_name}}}
    end

    SubscribedTo.mail_chimp_config.api_key.should eq "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-us1"
    SubscribedTo.mail_chimp_config.lists.should eq :mailing_list => {:id => "123456", :merge_vars => {"FNAME" => :first_name}}
  end

  it "should include the default instance methods" do
    User.included_modules.should include SubscribedTo::InstanceMethods
  end

  it "should add subscribe and update methods to the callback chain" do
    @user = Factory.build(:subscribed_user)
    @user.expects(:subscribe_to_list).once
    @user.save

    @user.first_name = "Edward"
    @user.expects(:update_list_member).once
    @user.save
  end

  # the default service is MailChimp
  context "for MailChimp" do
    it "should include the MailChimp instance methods" do
      User.included_modules.should include SubscribedTo::MailChimp::InstanceMethods
    end

    it "should provide the class with list_id and merge_vars methods" do
      SubscribedTo.mail_chimp do |config|
        config.lists = {:mailing_list => {:id => "123456", :merge_vars => {"FNAME" => :first_name}}}
      end

      User.list_id.should eq "123456"
      User.merge_vars.should eq "FNAME" => :first_name
    end
  end
end
