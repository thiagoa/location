require 'active_support/concern'

module Location
  module AddressValidatable
    extend ActiveSupport::Concern

    included do
      validates :street, length: { maximum: 150 }
      validates :number, length: { maximum: 20 }
      validates :complement, length: { maximum: 40 }
      validates :latitude, :longitude, numericality: true, allow_blank: true
      validates :district, length: { maximum: 150 }
      validates :city, length: { maximum: 150 }
      validates :state, length: { maximum: 150 }
    end
  end
end
