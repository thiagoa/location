FactoryGirl.define do
  factory :address_from_catalog, class: Location::Address do
    sequence(:postal_code) { |n| "59082-12#{n}" }
    sequence(:street) { |n| "Street #{n}" }
    sequence(:number) { |n| "#{n}" }
    sequence(:complement) { |n| "Subway #{n}" }
    association :addressable, factory: :catalog
    association :district, factory: :district
  end

  factory :catalog
end
