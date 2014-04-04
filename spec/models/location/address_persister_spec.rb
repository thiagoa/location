require 'location/address_normalizer'
require 'spec_helper'

module Location
  describe AddressPersister do
    before do
      stub_finder
    end

    after do
      unstub_finder
    end

    context "when an address doesn't exist" do
      context "with one address" do
        it "is correctly persisted" do
          normalizer = AddressNormalizer.new(::Person.new)
          persister = AddressPersister.new(normalizer, normalizer.address)
          persister.persist!

          expect(Location::Address.count).to eq 1
          expect(Location::District.count).to eq 1
          expect(Location::City.count).to eq 1
          expect(Location::City.count).to eq 1
        end
      end

      context "with two addresses" do
        it "is correctly persisted" do
          model = ::Person.new

          model.postal_code = '59000-001'
          model.street = 'Street 1'
          model.number = '111'

          normalizer = AddressNormalizer.new(model)
          normalizer.normalize!

          persister = AddressPersister.new(normalizer, normalizer.address)
          persister.persist!

          model = Person.new

          model.postal_code = '59001-002'
          model.street = 'Street 2'
          model.number = '222'

          normalizer = AddressNormalizer.new(model)
          normalizer.normalize!

          persister = AddressPersister.new(normalizer, normalizer.address)
          persister.persist!

          expect(Location::Address.count).to eq 2
          expect(Location::District.count).to eq 2
          expect(Location::City.count).to eq 2
          expect(Location::State.count).to eq 1
        end
      end
    end
  end
end
