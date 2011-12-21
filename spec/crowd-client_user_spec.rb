require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/crowd-client/user')

describe Crowd::Client::User do

  subject { Crowd::Client::User.new('user@example.com') }

  its(:username) { should == 'user@example.com' }
  its(:display_name) { should == 'Example User' }
  its(:email) { should == 'user@example.com' }

  describe "Creating a user" do
    it "should create a user with attributes" do
      user = Crowd::Client::User.new('new_user@example.com', {:password => 'test', :first_name => 'New', :last_name => 'User', :email => 'new_user@example.com'})
      user.save
      user.reload!
      user.destroy
    end
  end

  describe "Get groups for user" do
    it "should be in the group" do
      groups = subject.groups
      groups.size.should == 2
      groups.first.groupname.should == 'MyGroup'
    end
  end

  describe "#destroy" do
    before do
      Crowd::Client::User.create :username => 'delete@example.com', :password => 'test', :first_name => 'Delete', :last_name => 'Me', :email => 'delete@example.com'
    end
    subject { Crowd::Client::User.new('delete@example.com') }
    it "should delete the user" do
      subject.destroy
      expect { subject.reload! }.should raise_error Crowd::Client::Exception::NotFound, /User/
    end
  end
end
