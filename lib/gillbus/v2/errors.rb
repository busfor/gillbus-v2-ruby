module Gillbus::V2
  class Error < StandardError; end
  class AuthenticationRequired < Error; end
  class AuthenticationFailed < Error; end
end
