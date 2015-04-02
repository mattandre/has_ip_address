require "has_ip_address/migration.rb"
require "has_ip_address/request.rb"

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

      address_column = "#{name}".to_sym
      version_column = "#{name}_version".to_sym

      define_method "#{name}=" do |ip_address|
        unless ip_address.is_a?(Networking::IPAddress) || ip_address.nil?
          ip_address = Networking::IPAddress.parse(ip_address)
        end

        if ip_address.nil?
          self[address_column] = nil
          self[version_column] = nil

          @ip_addresses_cache[name] = nil
        else
          self[address_column] = ip_address.data
          self[version_column] = ip_address.version

          @ip_addresses_cache[name] = ip_address.freeze
        end
      end

      define_method name do
        if @ip_addresses_cache[name].nil?
          data = self[address_column]
          version = self[version_column]

          unless data.nil? || version.nil?
            @ip_addresses_cache[name] = Networking::IPAddress.parse_data(data, version)
          end
        end

        @ip_addresses_cache[name]
      end

      define_singleton_method "by_#{name}_version" do |version|
        where(version_column => version)
      end

      define_singleton_method "by_#{name}" do |ip_address|
        unless ip_address.is_a?(Networking::IPAddress) || ip_address.nil?
          ip_address = Networking::IPAddress.parse(ip_address)
        end

        if ip_address.present?
          data = ip_address.data
          version = ip_address.version
        end

        where(address_column => data)
          .send("by_#{name}_version", version)
      end

      define_singleton_method "before_#{name}" do |ip_address|
        unless ip_address.is_a?(Networking::IPAddress)
          ip_address = Networking::IPAddress.parse!(ip_address)
        end

        where("#{address_column} <= ?", ip_address.data)
          .send("by_#{name}_version", ip_address.version)
      end

      define_singleton_method "after_#{name}" do |ip_address|
        unless ip_address.is_a?(Networking::IPAddress)
          ip_address = Networking::IPAddress.parse!(ip_address)
        end

        where("#{address_column} >= ?", ip_address.data)
          .send("by_#{name}_version", ip_address.version)
      end
    end

    def has_ip_address_range(options = {})
      name = options.fetch(:name, :ip_address)

      start_name = "start_#{name}".to_sym
      end_name = "end_#{name}".to_sym

      has_ip_address(name: start_name)
      has_ip_address(name: end_name)

      define_method "#{name}_range" do
        start_ip_address = send(start_name)
        end_ip_address = send(end_name)

        return if start_ip_address.nil? || end_ip_address.nil?
        (start_ip_address..end_ip_address)
      end

      define_singleton_method "contains_#{name}" do |ip_address|
        send("before_#{start_name}", ip_address).send("after_#{end_name}", ip_address)
      end
    end

  end
end

ActiveRecord::Base.send :include, HasIPAddress
