module Location
  class City < ActiveRecord::Base
    has_many :districts
    belongs_to :state
  end
end
