require 'test_helper'

class HasIPAddressTest < ActiveSupport::TestCase

  test "truth" do
    assert_kind_of Module, HasIPAddress
  end

  test "event model" do
    Event.create(description: "Testing", ip_address_data: " \x01\r\xB8\x00\x00\x00\x00\x00\b\b\x00 \fAz", ip_address_prefix: 64, ip_address_version: 6)
    event = Event.first
    event.ip_address = Networking::IPAddress.parse("127.0.0.0/8")
    event.save!
    p event.ip_address.to_string
  end

end
