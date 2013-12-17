module Location
  class City < ActiveRecord::Base
    has_many :districts
    belongs_to :state

    accepts_nested_attributes_for :state

    validates :name, presence: true, length: { maximum: 150 }
  end
end
