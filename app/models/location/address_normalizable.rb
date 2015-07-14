require 'active_support/concern'
require 'location/address_normalizer'

module Location
  module AddressNormalizable
    def normalizable_address_attributes=(attributes)
      address_normalizer.normalizable = attributes
    end

    def address_normalizer
      (@normalizers ||= {})[postal_code] ||= Location::AddressNormalizer.new(self)
    end

    private

    def normalize_attributes!
      unless address_normalizer.normalize!
        errors.add :postal_code, %{Can't find address for #{postal_code}}
        false
      end
    end
  end
end
