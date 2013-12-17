require 'spec_helper'
require 'location/seeker'

module Location
  describe AddressData do
    it { should respond_to :postal_code }
    it { should respond_to :address }
    it { should respond_to :number }
    it { should respond_to :complement }
    it { should respond_to :district }
    it { should respond_to :city }
    it { should respond_to :state }
  end

  describe Seeker do
    subject(:seeker) { described_class.new(postal_code) }

    it { should respond_to :postal_code }
    it { should respond_to :service }
    it { should respond_to :address }
    it { should respond_to :error }

    let(:postal_code) { FactoryGirl.generate(:postal_code) }

    it "initializes with a postal code" do
      expect(seeker.postal_code).to eq postal_code
    end

    context 'when initialized without a service' do
      it 'has RepublicaService as the default service' do
        expect(seeker.service).to eq RepublicaService
      end
    end

    describe '.fetch' do
      let(:service)    { double }
      subject(:seeker) { described_class.new(postal_code, service) }

      context 'successful fetch' do
        it 'returns true' do
          expect(service).to receive(:fetch).with(postal_code, seeker.address)
          expect(seeker.fetch).to be_true
        end
      end

      context 'unsuccessful fetch' do
        it 'returns false' do
          service.stub(:fetch).and_raise(AddressException.new)
          expect(seeker.fetch).to be_false
        end
      end
    end
  end
end
