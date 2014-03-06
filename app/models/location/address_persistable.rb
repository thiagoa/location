require 'active_support/concern'
require 'location/address_normalizable'
require 'location/address_validatable'

module Location
  module AddressPersistable
    extend ActiveSupport::Concern

    attr_writer :address_persister

    included do
      after_save :persist_address!

      include Location::AddressValidatable
      include Location::AddressNormalizable
    end

    def address_persister
      @address_persister ||= AddressPersister.new(address_normalizer, address)
    end

    def persist_address!
      address_persister.persist!
    end
  end
end
