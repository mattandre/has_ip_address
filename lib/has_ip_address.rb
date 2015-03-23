require "has_ip_address/migration.rb"

module HasIPAddress
  extend ActiveSupport::Concern

  def initialize_dup(*) # :nodoc:
    @ip_addresses_cache = {}
    super
  end

  def reload(*) # :nodoc:
    clear_ip_addresses_cache
    super
  end

  private

    def clear_ip_addresses_cache # :nodoc:
      @ip_addresses_cache.clear if persisted?
    end

    def init_internals # :nodoc:
      @ip_addresses_cache = {}
      super
    end

  module ClassMethods

    def has_ip_address(options = {})
      name = options.fetch(:name, :ip_address)

      data_column = "#{name}_data".to_sym
      prefix_column = "#{name}_prefix".to_sym
      version_column = "#{name}_version".to_sym

      define_method "#{name}=" do |ip_address|
        unless ip_address.is_a?(Networking::IPAddress) || ip_address.nil?
          ip_address = Networking::IPAddress.parse(ip_address)
        end

        if ip_address.nil?
          self[data_column] = nil
          self[prefix_column] = nil
          self[version_column] = nil

          @ip_addresses_cache[name] = nil
        else
          self[data_column] = ip_address.data
          self[prefix_column] = ip_address.prefix.to_i
          self[version_column] = ip_address.version

          @ip_addresses_cache[name] = ip_address.freeze
        end
      end

      define_method name do
        if @ip_addresses_cache[name].nil?
          data = self[data_column]
          prefix = self[prefix_column]
          version = self[version_column]

          if data.present? && prefix.present? && version.present?
            @ip_addresses_cache[name] = Networking::IPAddress.parse_data(data, prefix, version)
          end
        end

        @ip_addresses_cache[name]
      end

    end
  end
end

ActiveRecord::Base.send :include, HasIPAddress
ActiveRecord::ConnectionAdapters::TableDefinition.send :include, HasIPAddress::Migration
