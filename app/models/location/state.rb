module Location
  class State < ActiveRecord::Base
    has_many :cities
    has_many :districts, through: :cities
    has_many :addresses, through: :districts

    validates :name, presence: true, length: { maximum: 150 }
  end
end
