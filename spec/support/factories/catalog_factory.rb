FactoryGirl.define do
  factory :address_from_catalog, class: Location::Address do |f|
    f.sequence(:postal_code) { |n| "5908212#{n}" }
    f.association :addressable, factory: :catalog
  end

  factory :catalog
end
