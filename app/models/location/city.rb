module Location
  class City < ActiveRecord::Base
    has_many :districts
    belongs_to :state

    validates :name, presence: true, length: { maximum: 150 }
  end
end
