require 'spec_helper'

describe "MailChimp Config" do
  before(:each) { @config = SubscribedTo::MailChimp::Config.new }

  it "should behave like a hash" do
    @config[:foo] = :bar
    @config[:foo].should eq :bar
  end

  it "should provide hash accessors" do
    @config.api_key = "1234567890"
    @config[:api_key].should eq "1234567890"
    @config[:api_key] = "0987654321"
    @config.api_key.should eq "0987654321"
  end

  it "should merge given options on initialization" do
    SubscribedTo::MailChimp::Config.new(:foo => :bar)[:foo].should eq :bar
  end
end
