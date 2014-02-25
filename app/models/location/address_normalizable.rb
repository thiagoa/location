require 'active_support/concern'
require 'location/address_normalizer'

module Location
  module AddressNormalizable
    extend ActiveSupport::Concern

    included do
      before_save :normalize_attributes!
    end

    def normalizable_address_attributes=(attributes)
      current_normalizer.normalizable = attributes
    end

    private

    def current_normalizer
      (@normalizers ||= {})[postal_code] ||= AddressNormalizer.new(self)
    end

    def normalize_attributes!
      unless current_normalizer.normalize!
        errors.add :postal_code, %{Can't find address for #{postal_code}}
        false
      end
    end
  end
end
