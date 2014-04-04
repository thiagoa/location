require 'spec_helper'
require 'location/address_persistable'

module Location
  describe AddressPersistable do
    before(:all) do
      stub_finder
    end

    after(:all) do
      unstub_finder
    end

    describe 'address persister' do
      context 'when not explicitly assigned' do
        it 'returns an address_persister object' do
          model = grab_model_with_persister
          expect(model.address_persister).to be_instance_of AddressPersister
        end

        it 'has the right address normalizer' do
          model = grab_model_with_persister
          address_persister = model.address_persister
          expect(address_persister.normalizer).to eq model.address_normalizer
        end

        it 'has the right model' do
          model = grab_model_with_persister
          address_persister = model.address_persister
          expect(address_persister.address).to eq model.address
        end
      end
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

    context 'with an existing record' do
      it 'assigns the address attributes to the virtual attributes' do
        person = grab_model_with_persister
        person.save!

        last_person = Person.last

        expect(last_person).to eq person

        expect(last_person.postal_code).to eq '59000001'
        expect(last_person.street).to eq 'You know my name, look up the number'
        expect(last_person.number).to eq '1983'
        expect(last_person.city).to eq 'Natal'
        expect(last_person.state).to eq 'RN'
        expect(last_person.district).to eq "That's right"
        expect(last_person.latitude).to be_nil
        expect(last_person.longitude).to be_nil
      end
    end

    context 'with a new record' do
      it 'does not fetch the virtual attribute values' do
        person = grab_model_with_persister
        person.street = 'street'

        expect(person.postal_code).to eq '59000-001'
        expect(person.street).to eq 'street'
        expect(person.number).to eq '1983'
        expect(person.city).to be_nil
        expect(person.state).to be_nil
        expect(person.district).to eq "That's right"
        expect(person.latitude).to be_nil
        expect(person.longitude).to be_nil
      end
    end
  end
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
