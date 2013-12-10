class Catalog < ActiveRecord::Base
  has_many :addresses, class_name: Location::Address, as: :addressable
end
