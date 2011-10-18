module Crowd::Client
  class Exception < RuntimeError; end
  class Exception::UnkownError < Crowd::Client::Exception; end
  class Exception::InactiveAccount < Crowd::Client::Exception; end
  class Exception::AuthenticationFailed < Crowd::Client::Exception; end
end



