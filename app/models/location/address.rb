module Location
  class Address < ActiveRecord::Base
    belongs_to :district
    belongs_to :addressable, polymorphic: true

    validates :address, presence: true, length: { maximum: 150 }
    validates :number, length: { maximum: 20 }
    validates :complement, length: { maximum: 40 }
    validates :latitude, :longitude, numericality: true, allow_blank: true
    validates :district, presence: true
    validates :postal_code, presence: true

    before_save :format_postal_code

    private
      def format_postal_code
        postal_code.gsub!(/[^0-9]/, '')
      end
  end
end
