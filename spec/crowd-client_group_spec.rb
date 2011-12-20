require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../lib/crowd-client/group')

describe Crowd::Client::Group do

  use_vcr_cassette

  subject { Crowd::Client::Group.new('MyGroup') }

  describe "#add_user" do
    it "should raise Exception::NotFound for missing user" do
      fake_user = Crowd::Client::User.new('fake')
      expect { subject.add_user(fake_user) }.should raise_error Crowd::Client::Exception::NotFound, /User/
    end

    describe "missing group" do
      subject { Crowd::Client::Group.new('FakeGroup') }

      it "should raise Exception::NotFound for missing group" do
        user = Crowd::Client::User.new('user@example.com')
        expect { subject.add_user(user) }.should raise_error Crowd::Client::Exception::NotFound, /Group/
      end
    end
  end

  describe "#users" do
    it "should return all of the users in the group" do
      users = subject.users
      users.size.should == 1
      users.first.username.should == 'user@example.com'
    end
  end
end
