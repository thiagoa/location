require 'active_support/concern'
require 'location/address_attributable'
require 'location/address_validatable'
require 'location/address_normalizable'

module Location
  module AddressPersistable
    extend ActiveSupport::Concern

    attr_writer :address_persister

    def address_persister
      @address_persister ||= AddressPersister.new(address_normalizer, address)
    end

    def persist_address!
      address_persister.persist!
    end
  end
end
