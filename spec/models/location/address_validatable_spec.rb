require 'spec_helper'
require 'location/address_validatable'

describe AddressValidatable do
  let(:model) {
    Class.new do
      include ActiveModel::Model
      include AddressValidatable

      def self.model_name
        ActiveModel::Name.new(self, nil, 'anonymous')
      end
    end.new
  }

  it 'has a postal_code accessor' do
    expect(model).to respond_to_option(:postal_code)
  end

  it 'has a street accessor' do
    expect(model).to respond_to_option(:street)
  end

  it 'has a number accessor' do
    expect(model).to respond_to_option(:number)
  end

  it 'has a complement accessor' do
    expect(model).to respond_to_option(:complement)
  end

  it 'has a district accessor' do
    expect(model).to respond_to_option(:district)
  end

  it 'has a city accessor' do
    expect(model).to respond_to_option(:city)
  end

  it 'has a state accessor' do
    expect(model).to respond_to_option(:state)
  end

  it 'has a latitude accessor' do
    expect(model).to respond_to_option(:latitude)
  end

  it 'has a longitude accessor' do
    expect(model).to respond_to_option(:longitude)
  end

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
