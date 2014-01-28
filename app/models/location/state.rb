module Location
  class State < ActiveRecord::Base
    has_many :cities, dependent: :destroy
    has_many :districts, through: :cities
    has_many :addresses, through: :districts

    validates :name, length: { maximum: 150 }
  end
end
