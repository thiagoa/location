require 'spec_helper'
require 'location/address_persistable'

module Location
  describe AddressPersistable do
    before(:all) do
      @default_service = Location.configuration.default_service
      setup_finder
    end

    after(:all) do
      Location.configuration.default_service = @default_service
    end

    context 'when saving a model' do
      it 'calls persist! on address_persister' do
        model = grab_model
        persister = grab_persister(model)
        model.address_persister = persister

        expect(persister).to receive(:persist!).once

        model.save!
      end

      context 'with one postal code and one address' do
        it 'saves the address correctly' do
          grab_model_with_persister.save!

          expect(Location::Address.count).to eq 1
          expect(Location::District.count).to eq 1
          expect(Location::City.count).to eq 1
          expect(Location::State.count).to eq 1
        end
      end

      context 'with one postal code and two addresses' do
        it 'saves the addresses correctly' do
          model_one = grab_model_with_persister(postal_code: '59000-001')
          model_two = grab_model_with_persister(postal_code: '59000-001')

          model_one.save!
          model_two.save!

          expect(Location::Address.count).to eq 2
          expect(Location::District.count).to eq 2
          expect(Location::City.count).to eq 1
          expect(Location::State.count).to eq 1
        end
      end

      context 'with two postal codes and three addresses' do
        it 'saves the addresses correctly' do
          model_one = grab_model_with_persister(postal_code: '59000-001')
          model_two = grab_model_with_persister(postal_code: '59000-001')
          model_three = grab_model_with_persister(postal_code: '59001-002')

          model_one.save!
          model_two.save!
          model_three.save!

          expect(Location::Address.count).to eq 3
          expect(Location::District.count).to eq 3
          expect(Location::City.count).to eq 2
          expect(Location::State.count).to eq 1
        end
      end
    end
  end
end

def setup_finder
  Location::Services::StubbedService.set_result('59000-001', {
    city: 'Natal',
    state: 'RN',
    district: 'Ponta Negra'
  })

  Location::Services::StubbedService.set_result('59001-002', {
    city: 'Parnamirim',
    state: 'RN',
    district: 'Centro'
  })

  Location.configuration.default_service = Location::Services::StubbedService
end

def grab_model(attributes = {})
  default_attributes ||= {
    postal_code: '59000-001',
    street:      'You know my name, look up the number',
    district:    "That's right",
    number:      '1983'
  }

  Person.new(default_attributes.merge(attributes))
end

def grab_persister(model)
  persister = Location::AddressPersister.new(
    model.address_normalizer,
    model.address
  )

  model.address_persister = persister
  persister
end

def grab_model_with_persister(attributes = {})
  model = grab_model(attributes)
  grab_persister(model)
  model
end
