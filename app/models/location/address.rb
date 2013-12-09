module Location
  class Address < ActiveRecord::Base
    belongs_to :district
    belongs_to :addressable, polymorphic: true
  end
end
