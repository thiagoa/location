require 'spec_helper'
require 'location/address_validations'

describe AddressValidations do
  let(:model) {
    Class.new do
      include ActiveModel::Model
      include AddressValidations

      def self.model_name
        ActiveModel::Name.new(self, nil, 'anonymous')
      end
    end.new
  }

  it 'ensures length of state' do
    expect(model).to ensure_length_of(:state).is_at_most(150)
  end

  it 'ensures length of city' do
    expect(model).to ensure_length_of(:city).is_at_most(150)
  end

  it 'ensures length of district' do
    expect(model).to ensure_length_of(:district).is_at_most(150)
  end

  it 'ensures length of street' do
    expect(model).to ensure_length_of(:street).is_at_most(150)
  end

  it 'ensures length of number' do
    expect(model).to ensure_length_of(:number).is_at_most(20)
  end

  it 'ensures length of complement' do
    expect(model).to ensure_length_of(:complement).is_at_most(40)
  end

  it 'validates numericality of latitude' do
    expect(model).to validate_numericality_of(:latitude)
  end

  it 'validates numericality of longitude' do
    expect(model).to validate_numericality_of(:longitude)
  end
end
