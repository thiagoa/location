module Location
  class City < ActiveRecord::Base
    has_many :districts
    belongs_to :state, dependent: :destroy

    validates :name, length: { maximum: 150 }
  end
end
