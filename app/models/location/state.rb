module Location
  class State < ActiveRecord::Base
    has_many :cities

    validates :name, presence: true, length: { maximum: 150 }
  end
end
