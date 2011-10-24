require "crowd-client/version"
require "crowd-client/exceptions"
require "ostruct"
require "faraday"
require "faraday_middleware"
require "patron"
require "json"

module Crowd
  module Client
    extend self
    @config = ::OpenStruct.new({
      :url         => 'http://127.0.0.1:8095/crowd/rest/usermanagement/1/',
      :application => 'application',
      :password    => 'password',
      :logger       => false
    })

    def config
      @config
    end

    def login(username, password)
      response = connection.post('session', :username => username, :password => password)

      raise Exception::AuthenticationFailed.new if response.status == 400 && response.body['reason'] == 'INVALID_USER_AUTHENTICATION'
      raise Exception::InactiveAccount.new if response.status == 400 && response.body['reason'] == 'INACTIVE_ACCOUNT'
      raise Exception::UnkownError if response.status != 201
      return response.body['token']
    end

    def valid_session?(token)
      response = connection.post("session/#{token}", {})
      response.status == 200
    end

    def logout(token)
      response = connection.delete("session/#{token}", {})
      raise Exception::UnkownError if response.status != 204
    end

    def user(token)
      response = connection.get("session/#{token}") do |request|
        request.params[:expand] = 'user'
      end
      response.body['user']
    end

    def user_groups(username)
      response = connection.get("user/group/nested") do |request|
        request.params[:username] = username
      end
      response.body['groups'].collect{|group| group['name']}
    end

    def in_group?(username, group_name)
      response = connection.get("user/group/nested") do |request|
        request.params[:username] = username
        request.params[:groupname] = group_name
      end
      response.status == 200
    end

    def connection
      ::Faraday::Connection.new(
        :url        => config.url,
        :headers    => { :accept => 'application/json' },
        :user_agent => "Crowd Client for Ruby/#{VERSION}"
      ) do |builder|
          builder.request  :json
          builder.use Faraday::Response::Logger, config.logger if config.logger
          builder.use Faraday::Response::ParseJson
          builder.adapter  :patron
      end.tap {|connection| connection.basic_auth config.application, config.password }
    end
  end
end
