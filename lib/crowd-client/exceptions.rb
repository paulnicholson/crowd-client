module Crowd::Client
  class Exception < RuntimeError; end
  class Exception::UnknownError < Crowd::Client::Exception; end
  class Exception::InactiveAccount < Crowd::Client::Exception; end
  class Exception::AuthenticationFailed < Crowd::Client::Exception; end
  class Exception::NotFound < Crowd::Client::Exception; end
end



