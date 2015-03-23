module HasIPAddress
  extend ActiveSupport::Concern

  module ClassMethods

    # Columns
    # ip_address => (0..2^32) or (0..2^128)
    # ip_version => 4 or 6
    # ip_prefix => (0..32) or (0..128)
    #
    def has_ip_address(options = {})
      name = options.fetch(:name, :ip)

      ip_address_column = "#{name}_address".to_sym
      ip_prefix_column = "#{name}_prefix".to_sym
      ip_version_column = "#{name}_version".to_sym

      define_method "#{name}=" do |ip|
        ip = Networking::IPAddress.parse(ip)

        self[ip_address_column] = ip.to_i
        self[ip_prefix_column] = ip.prefix.to_i
        self[ip_version_column] = ip.version

        instance_variable_set("@#{name}", ip)
      end

      define_method name do
        ip_address = self[ip_address_column]
        ip_prefix = self[ip_prefix_column]
        ip_version = self[ip_version_column]

        if ip_address.present? && ip_prefix.present? && ip_version.present?
          Networking::IPAddress.parse_value(ip_address, ip_prefix, ip_version)
        end
      end

    end
  end
end

ActiveRecord::Base.send :include, HasIPAddress
