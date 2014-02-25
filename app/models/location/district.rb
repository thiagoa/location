require 'concerns/find_or_create'

module Location
  class District < ActiveRecord::Base
    include FindOrCreate

    has_many :addresses
    belongs_to :city
  end
end
