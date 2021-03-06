require 'concerns/find_or_create'

module Location
  class State < ActiveRecord::Base
    include FindOrCreate

    has_many :cities, dependent: :destroy
    has_many :districts, through: :cities
    has_many :addresses, through: :districts
  end
end
