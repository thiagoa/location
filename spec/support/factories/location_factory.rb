FactoryGirl.define do
  sequence(:postal_code) { |n| "59022-11#{n}" }

  factory :state, class: Location::State do
    name { %w{Pernambuco Alagoas Amazonas Sergipe}.sample }
  end

  factory :city, class: Location::City do
    name { %w{Recife Natal Fortaleza }.sample }
    state
  end

  factory :district, class: Location::District do
    name { %w{Tirol Satelite Mirassol}.sample }
    city
  end

  factory :address, class: Location::Address do
    postal_code
    sequence(:street) { |n| "Street #{n}" }
    sequence(:number)
    sequence(:complement) { |n| "Subway #{n}" }
    district
  end
end
