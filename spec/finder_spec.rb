require 'spec_helper'
require 'location/finder'

module Location
  describe Finder do
    let(:postal_code)     { FactoryGirl.generate(:postal_code) }
    let(:default_service) { RepublicaService.new }

    it "initializes with a postal code and a service" do
      finder = described_class.new(postal_code, default_service)
      expect(finder.postal_code).to eq postal_code
      expect(finder.service).to eq default_service
    end

    describe 'attributes' do
      subject(:finder) do
        described_class.new(postal_code, default_service) 
      end

      it { should respond_to :postal_code }
      it { should respond_to :service }
      it { should respond_to :address }
      it { should respond_to :error }

      its(:address) { should be_a Finder::Address }
    end

    describe '.find' do
      it 'yields self' do
        finder = described_class.new(postal_code, default_service)
        expect { |b| finder.find(&b) }.to yield_with_args finder
      end

      let(:service) { double }

      before(:each) do
        @finder = described_class.new(postal_code, service)
      end

      context 'no find' do
        it 'returns nil for success?' do
          expect(@finder.success?).to be_nil
        end
      end

      context 'successful find' do
        it 'returns true' do
          expect(service).to receive(:fetch).with(postal_code, @finder.address)
          expect(@finder.find).to be_true
          expect(@finder.success?).to be_true
        end
      end

      context 'unsuccessful find' do
        it 'returns false' do
          service.stub(:fetch).and_raise(ServiceException.new)
          expect(@finder.find).to be_false
          expect(@finder.success?).to be_false
        end
      end
    end

    describe '#build' do
      subject(:finder)  { described_class.build(postal_code) }

      it { should be_instance_of described_class }
      its(:service) { should be_a default_service.class }
    end
  end

  describe Finder::Address do
    it { should respond_to :postal_code }
    it { should respond_to :address }
    it { should respond_to :number }
    it { should respond_to :complement }
    it { should respond_to :district }
    it { should respond_to :city }
    it { should respond_to :state }
  end
end
