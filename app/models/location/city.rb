require 'concerns/find_or_create'

module Location
  class City < ActiveRecord::Base
    include FindOrCreate

    has_many :districts
    belongs_to :state, dependent: :destroy
  end
end
