module Location
  class District < ActiveRecord::Base
    has_many :addresses
    belongs_to :city

    accepts_nested_attributes_for :city

    validates :name, presence: true, length: { maximum: 150 }
  end
end
