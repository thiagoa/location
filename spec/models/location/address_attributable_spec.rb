require 'spec_helper'
require 'location/address_validatable'

describe Location::AddressAttributable do
  let(:model) {
    Class.new do
      include Location::AddressAttributable
    end.new
  }

  attributes = %i{postal_code street number complement
                  district city state latitude longitude}

  attributes.each do |attr|
    it "has #{attr.to_s} accessor" do
      expect(model).to respond_to_option(attr)
    end
  end

  context 'when the model has an address attribute' do
    it 'gets the values from the address' do
      address = double({
        postal_code: 'postal_code',
        street:      'street',
        number:      'number',
        complement:  'complement',
        latitude:    'latitude',
        longitude:   'longitude',
        city:        'city',
        state:       nil,
        district:    nil
      })

      allow(model).to receive(:address) { address }
      model.city = 'is not nil'

      expect(model.postal_code).to eq 'postal_code'
      expect(model.street).to eq 'street'
      expect(model.number).to eq 'number'
      expect(model.complement).to eq 'complement'
      expect(model.latitude).to eq 'latitude'
      expect(model.longitude).to eq 'longitude'
      expect(model.city).to eq 'is not nil'
      expect(model.state).to be_nil
      expect(model.district).to be_nil
    end

    context 'when an address attribute responds to :name' do
      it 'returns the name value for that attribute' do
        address = double({
          postal_code: 'postal_code',
          street:      'street',
          number:      nil,
          complement:  nil,
          latitude:    'latitude',
          longitude:   'longitude',
          city:        double(name: 'city'),
          state:       double(name: 'state'),
          district:    nil
        })

        allow(model).to receive(:address) { address }
        model.district = 'is not nil'

        expect(model.postal_code).to eq 'postal_code'
        expect(model.street).to eq 'street'
        expect(model.number).to be_nil
        expect(model.complement).to be_nil
        expect(model.latitude).to eq 'latitude'
        expect(model.longitude).to eq 'longitude'
        expect(model.city).to eq 'city'
        expect(model.state).to eq 'state'
        expect(model.district).to eq 'is not nil'
      end
    end
  end
end
