require 'crowd-client'

class Crowd::Client::Group
  attr_accessor :groupname

  def initialize(groupname)
    self.groupname = groupname
  end

  def users
    response = connection.get('group/user/nested') do |request|
      request.params[:groupname] = groupname
    end
    raise ::Crowd::Client::Exception::NotFound.new("Group '#{groupname}' was not found") if response.status == 404
    response.body['users'].collect do |user|
      ::Crowd::Client::User.new(user['name'])
    end
  end

  def add_user(user)
    response = connection.post('group/user/direct', :name => user.username) do |request|
      request.params[:groupname] = groupname
    end
    raise ::Crowd::Client::Exception::NotFound.new("Group '#{groupname}' was not found") if response.status == 404
    raise ::Crowd::Client::Exception::NotFound.new("User '#{user.username}' was not found") if response.status == 400
    raise ::Crowd::Client::Exception::UnknownError if response.status != 201
  end

  private
    def connection
      ::Crowd::Client.connection
    end
end
