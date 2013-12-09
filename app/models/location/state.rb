module Location
  class State < ActiveRecord::Base
    has_many :cities
  end
end
