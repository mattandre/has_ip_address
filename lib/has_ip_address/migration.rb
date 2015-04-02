module HasIPAddress
  module Migration
    extend ActiveSupport::Concern

    def ip_address(name = :ip_address)
      binary  "#{name}", limit: 16
      integer "#{name}_version", limit: 1
    end

  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.send :include, HasIPAddress::Migration
