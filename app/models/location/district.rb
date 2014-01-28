module Location
  class District < ActiveRecord::Base
    has_many :addresses
    belongs_to :city

    validates :name, length: { maximum: 150 }
  end
end
