require 'super_form'
require 'location/address_validatable'
require 'location/address_normalizable'
require 'location/address_persister'

module Location
  class AddressForm
    include SuperForm
    include AddressValidatable
    include AddressNormalizable

    def self.default_presence_attributes
      %i{postal_code street district}
    end

    def self.string_attributes
      %i{postal_code street number complement district city state}
    end

    def self.float_attributes
      %i{latitude longitude}
    end

    string_attributes.each { |attr| field attr, Field::Text }
    float_attributes.each  { |attr| field attr, Field::Float }

    (string_attributes + float_attributes).each do |attr|
      validates attr, presence: true, if: ->(a){ a.presence[attr] }
    end

    attr_accessor :address

    def presence
      @presence || validate_presence_of(AddressForm.default_presence_attributes)
    end

    def validate_presence_of(attributes)
      attributes = Array(attributes)

      @presence = self.attributes.keys.inject({}) do |hash, attr|
        hash[attr] = attributes.include?(attr)
        hash
      end
    end

    private

    def persist!
      AddressPersister.new(address_normalizer, address).persist!
    end
  end
end
