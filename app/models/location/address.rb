module Location
  class Address < ActiveRecord::Base
    belongs_to :district
    belongs_to :addressable, polymorphic: true
    has_one :city, through: :district
    has_one :state, through: :city

    before_save :format_postal_code

    validates :address, length: { maximum: 150 }
    validates :number, length: { maximum: 20 }
    validates :complement, length: { maximum: 40 }
    validates :latitude, :longitude, numericality: true, allow_blank: true

    scope :full, ->{ eager_load(:district).eager_load(:city).eager_load(:state) }
    default_scope { full }

    def to_hash
      {
        postal_code: self.postal_code,
        address:     self.address,
        number:      self.number,
        complement:  self.complement,
        district:    self.district.try(:name),
        city:        self.city.try(:name),
        state:       self.state.try(:name)
      }
    end

    private

    def format_postal_code
      postal_code.gsub!(/[^0-9]/, '') if postal_code.present?
    end
  end
end


