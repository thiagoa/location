module Location
  class District < ActiveRecord::Base
    has_many :addresses
    belongs_to :city
  end
end
