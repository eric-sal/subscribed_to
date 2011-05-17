require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Subscribed To" do
  it "should add methods to the callback chain" do
    @user = Factory.build(:new_user)
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
