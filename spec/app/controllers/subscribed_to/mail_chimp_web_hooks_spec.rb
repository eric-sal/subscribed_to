require 'spec_helper'
require 'rspec/rails'

describe SubscribedTo::MailChimpWebHooksController do
  include RSpec::Rails::ControllerExampleGroup

  before do
    SubscribedTo.mail_chimp do |config|
      config.lists = {
        :mailing_list => {
          :id => "abc123",
          :merge_vars => {"FNAME" => :first_name, "LNAME" => :last_name, "EMAIL" => :email}}}

      # normally not set in config, but necessary for testing
      config.enabled_models = {"abc123" => ["User"]}

      config.secret_key = "abc123"
    end
  end

  it "should respond with 404 to a request without a valid secret key" do
    post :create
    response.code.should eq "404"

    post :create, { :key => "bad_key" }
    response.code.should eq "404"
  end

  it "should respond with 200 to a request with a valid secret key" do
    SubscribedTo::MailChimp::WebHook.stubs(:process).returns(true)
    post :create, { :key => "abc123" }
    response.code.should eq "200"
  end

  it "should quietly fail and log the error if no member is found" do
    Rails.logger.expects(:warn).once
    expect do
      post :create, {
        "key" => "abc123",
        "type" => "subscribe",
        "data" => {
          "list_id" => "abc123",
          "web_id" => "231546749",
          "merges" => {
            "EMAIL" => "fake.user@email.com" }}}
    end.not_to raise_exception
  end

  it "should write a warning to the logger if the event is not supported" do
    Rails.logger.expects(:warn).once
    expect do
      post :create, {
        "key" => "abc123",
        "type" => "nonevent",
        "data" => { "list_id" => "abc123" }}
    end.not_to raise_exception
  end

  context "for a new user" do
    before(:each) do
      @user = Factory.build(:non_subscribed_user)
      @user.stubs(:subscribe_to_list)
      @user.save
      @user.expects(:update_list_member).never
    end

    context "when they subscribe" do
      it "should set subscribed_to_list to true, and set the mail_chimp_id" do
        @user.mail_chimp_id.should be_nil
        expect do
          expect do
            post :create, {
              "key" => "abc123",
              "type" => "subscribe",
              "data" => {
                "list_id" => "abc123",
                "web_id" => "231546749",
                "merges" => {
                  "EMAIL" => @user.email }}}
          end.to change { @user.reload.subscribed_to_list }.from(false).to(true)
        end.to change { @user.mail_chimp_id }.to(231546749)
      end
    end
  end

  context "for an existing user" do
    before(:each) do
      # user was updated 0:11 ago
      pretend_now_is(Time.zone.now - 11.seconds) do
        @user = Factory.build(:subscribed_user)
        @user.stubs(:subscribe_to_list)
        @user.save
        @user.expects(:update_list_member).never
      end
    end

    context "when they unsubscribe" do
      it "should set subscribed_to_list to false" do
        expect do
          post :create, {
            "key" => "abc123",
            "type" => "unsubscribe",
            "data" => {
              "list_id" => "abc123",
              "web_id" => "123",
              "merges" => {
                "EMAIL" => @user.email }}}
        end.to change { @user.reload.subscribed_to_list }.from(true).to(false)
      end
    end

    context "when they change their email" do
      it "should update the user email" do
        expect do
          post :create, {
            "key" => "abc123",
            "type" => "upemail",
            "data" => {
              "list_id" => "abc123",
              "new_email" => "my.new@email.com",
              "old_email" => @user.email }}
        end.to change { @user.reload.email }.to("my.new@email.com")
      end
    end

    context "when they change their profile information" do
      it "should update the attributes defined in the merge vars config" do
        expect do
          expect do
            expect do
              post :create, {
                "key" => "abc123",
                "type" => "profile",
                "data" => {
                  "list_id" => "abc123",
                  "web_id" => "123",
                  "merges" => {
                    "EMAIL" => "my.new@email.com",
                    "FNAME" => "John",
                    "LNAME" => "Locke" }}}
            end.to change { @user.reload.email }.to("my.new@email.com")
          end.to change { @user.first_name }.to("John")
        end.to change { @user.last_name }.to("Locke")
      end
    end
  end
end
