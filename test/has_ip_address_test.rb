require 'test_helper'

class HasIPAddressTest < ActiveSupport::TestCase

  setup do
    @ip_address = Networking::IPAddress.parse("172.192.45.0/24")
    @event = Event.create(description: "Testing", ip_address: @ip_address)
  end

  test "module" do
    assert_kind_of Module, HasIPAddress
  end

  test "create version 4 from components" do
    data = "\xAC\x10\n\x01"
    prefix = 24

    event = Event.create(description: "Testing", ip_address_data: data, ip_address_prefix: prefix, ip_address_version: 4)

    assert_instance_of Networking::IPv4Address, event.ip_address
    assert_equal "172.16.10.1/24", event.ip_address.to_string
  end

  test "create version 4 from components without prefix" do
    data = "\xAC\x10\n\x01"

    event = Event.create(description: "Testing", ip_address_data: data, ip_address_version: 4)

    assert_instance_of Networking::IPv4Address, event.ip_address
    assert_equal "172.16.10.1/32", event.ip_address.to_string
  end

  test "create version 4 from object" do
    ip_address = Networking::IPAddress.parse("145.45.45.54/24")

    event = Event.create(description: "Testing", ip_address: ip_address)

    assert_instance_of Networking::IPv4Address, event.ip_address
    assert_equal "145.45.45.54/24", event.ip_address.to_string
  end

  test "create version 4 from string" do
    event = Event.create(description: "Testing", ip_address: "145.45.45.54/24")

    assert_instance_of Networking::IPv4Address, event.ip_address
    assert_equal "145.45.45.54/24", event.ip_address.to_string

    event = Event.create(description: "Testing", ip_address: "256.45.45.54/24")
    assert_equal nil, event.ip_address
  end

  test "create version 6 from components" do
    data = " \x01\r\xB8\x00\x00\x00\x00\x00\b\b\x00 \fAz"
    prefix = 64

    event = Event.create(description: "Testing", ip_address_data: data, ip_address_prefix: prefix, ip_address_version: 6)

    assert_instance_of Networking::IPv6Address, event.ip_address
    assert_equal "2001:db8::8:800:200c:417a/64", event.ip_address.to_string
  end

  test "create version 6 from components without prefix" do
    data = " \x01\r\xB8\x00\x00\x00\x00\x00\b\b\x00 \fAz"

    event = Event.create(description: "Testing", ip_address_data: data, ip_address_version: 6)

    assert_instance_of Networking::IPv6Address, event.ip_address
    assert_equal "2001:db8::8:800:200c:417a/128", event.ip_address.to_string
  end

  test "create version 6 from object" do
    ip_address = Networking::IPAddress.parse("2001:db8:800:200c::/64")

    event = Event.create(description: "Testing", ip_address: ip_address)

    assert_instance_of Networking::IPv6Address, event.ip_address
    assert_equal "2001:db8:800:200c::/64", event.ip_address.to_string
  end

  test "create version 6 from string" do
    event = Event.create(description: "Testing", ip_address: "2001:db8:800:200c::/64")

    assert_instance_of Networking::IPv6Address, event.ip_address
    assert_equal "2001:db8:800:200c::/64", event.ip_address.to_string

    event = Event.create(description: "Testing", ip_address: "fz01:db8:800:200c::/64")

    assert_equal nil, event.ip_address
  end

  test "set version 4 from object" do
    @event.ip_address = Networking::IPAddress.parse("145.45.45.54")

    assert_instance_of Networking::IPv4Address, @event.ip_address
    assert_equal "145.45.45.54/32", @event.ip_address.to_string
  end

  test "set version 4 from string" do
    @event.ip_address = "145.45.45.54"

    assert_instance_of Networking::IPv4Address, @event.ip_address
    assert_equal "145.45.45.54/32", @event.ip_address.to_string

    @event.ip_address = "256.45.45.54/24"
    assert_equal nil, @event.ip_address
  end

end
