require 'crowd-client'

class Crowd::Client::User
  attr_accessor :username, :new_record

  def initialize(username, attributes=nil)
    self.username = username
    self.new_record = true
    assign_attributes attributes, true
  end

  def self.create(attributes)
    new('', attributes).tap {|user| user.save }
  end

  def ==(other)
    username == (other && other.username)
  end

  def first_name
    user_attributes['first-name']
  end

  def last_name
    user_attributes['last-name']
  end

  def display_name
    user_attributes['display-name']
  end

  def email
    user_attributes['email']
  end

  def active
    user_attributes['active']
  end

  def groups(reload=false)
    return @groups if @groups && !reload
    response = connection.get("user/group/nested") do |request|
      request.params[:username] = username
    end
    raise ::Crowd::Client::Exception::NotFound.new("User '#{user.username}' was not found") if response.status == 404
    @groups = response.body['groups'].collect do |group|
      ::Crowd::Client::Group.new(group['name'])
    end
  end

  def reload!
    @groups = nil
    user_attributes(true)
  end

  def update_attibutes(attributes)
    assign_attributes attributes
    save
  end

  def save
    if new_record
      response = connection.post('user', {'name' => username, 'active' => true}.merge(@attributes))
      self.new_record = false
      raise ::Crowd::Client::Exception::UnknownError.new(response.body.to_s) if response.status != 201
    else
      response = connection.put('user', {'name' => username}.merge(@attributes)) do |request|
        request.params[:username] = username
      end
      raise ::Crowd::Client::Exception::NotFound.new("User with username '#{username}' was not found.") if response.status == 404
      raise ::Crowd::Client::Exception::UnknownError.new(response.body) if response.status != 204
    end
  end

  def destroy
    response = connection.delete('user') do |request|
      request.params[:username] = username
    end
    raise ::Crowd::Client::Exception::NotFound.new("User '#{user.username}' was not found") if response.status == 404
    raise ::Crowd::Client::Exception::UnknownError.new(response.body.to_s) if response.status != 204
  end

  def authenticate?(password)
    response = connection.post('authentication', :value => password) do |request|
      request.params[:username] = username
    end
    response.status == 200
  end

  def change_password(password)
    response = connection.put('user/password', :value => password) do |request|
      request.params[:username] = username
    end
    raise ::Crowd::Client::Exception::NotFound.new("User '#{user.username}' was not found") if response.status == 404
    raise ::Crowd::Client::Exception::UnknownError.new(response.body.to_s) if response.status != 204
  end

  private
    def connection
      ::Crowd::Client.connection
    end

    def password=(password)
      write_attribute :password, {:value => password }
    end

    def assign_attributes(attributes, include_private=false)
      attributes && attributes.each do |k,v|
        respond_to?(:"#{k}=", include_private) ? send(:"#{k}=", v) : write_attribute(k.to_s.gsub(/[_ ]/, '-'), v)
      end
    end

    def write_attribute(attribute, value)
      @attributes ||= {}
      @attributes[attribute.to_s] = value
    end

    def user_attributes(reload=false)
      return @attributes if @attributes && !reload
      response = connection.get("user?username=#{username}")
      raise ::Crowd::Client::Exception::NotFound.new("User with username '#{username}' was not found.") if response.status == 404
      self.new_record = false
      @attributes = response.body
    end
end
