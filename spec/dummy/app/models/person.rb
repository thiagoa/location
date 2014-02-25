class Person < ActiveRecord::Base
  include Location::AddressPersistable

  has_one :address, as: :addressable, class_name: 'Location::Address'
end
