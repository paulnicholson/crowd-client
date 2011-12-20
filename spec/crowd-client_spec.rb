require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/crowd-client')

describe Crowd::Client do

  use_vcr_cassette #:record => :all

  describe "#config" do
    subject { Crowd::Client.config }

    its(:url) { should == "http://127.0.0.1:8095/crowd/rest/usermanagement/1/" }
    its(:application) { should == 'application' }
    its(:password) { should == 'password' }
  end

  describe "#login" do

    it "should authenticate and return a session token" do
      subject.login('user@example.com', 'password').should =~ /[A-Za-z0-9]{24}/
    end

    it "should raise Crowd::Client::Exception::AuthenticationFailed if authentication fails" do
      lambda { subject.login('user@example.com', 'wrong_password') }.should raise_error(Crowd::Client::Exception::AuthenticationFailed)
    end


    it "should raise Crowd::Client::Exception::InactiveAccount if an account is inactive" do
      lambda { subject.login('inactive_user@example.com', 'password') } .should raise_error(Crowd::Client::Exception::InactiveAccount)
    end
  end

  describe "#valid_session?" do

    it "should validate the current session" do
      token = subject.login('user@example.com', 'password')
      subject.valid_session?(token).should be_true
    end
  end

  describe "#in_group?" do

    it "should confirm users are in groups" do
      subject.in_group?('user@example.com', 'MyGroup').should be_true
      subject.in_group?('user@example.com', 'OtherGroup').should be_false
    end
  end

  describe "#user(token)" do

    it "should return the expanded user" do
      token = subject.login('user@example.com', 'password')
      subject.user(token)['name'].should == 'user@example.com'
    end
  end

  describe "#user_groups(username)" do
    it "should return the groups of the user" do
      group_names = subject.user_groups('user@example.com').collect{|group| group['name']}
      group_names.size.should == 2
      group_names.should include('users')
      group_names.should include('MyGroup')
      group_names.should_not include('OtherGroup')
    end
  end

  describe "#logout" do
    it "should logout the current session" do
      token = subject.login('user@example.com', 'password')
      subject.valid_session?(token).should be_true
      subject.logout(token)
      subject.valid_session?(token).should be_false
    end

  end
end
