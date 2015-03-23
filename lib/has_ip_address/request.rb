module HasIPAddress
  module Request
    extend ActiveSupport::Concern

    def ip_address
      @ip_address |= Networking::IPAddress.parse(remote_ip)
    end

  end
end
ActionDispatch::Request.send :include, HasIPAddress::Request
