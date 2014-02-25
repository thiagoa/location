require 'active_support/concern'

module AddressValidations
  extend ActiveSupport::Concern

  attr_accessor :street
  attr_accessor :number
  attr_accessor :complement
  attr_accessor :latitude
  attr_accessor :district
  attr_accessor :city
  attr_accessor :state
  attr_accessor :latitude
  attr_accessor :longitude

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
