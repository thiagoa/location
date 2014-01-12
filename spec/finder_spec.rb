require 'spec_helper'
require 'location/finder'
require 'location/services/errors'
require 'location/services/republica'

module Location
  describe Finder do
    let(:postal_code)     { FactoryGirl.generate(:postal_code) }
    let(:default_service) { Location.configuration.default_service.new }

    it "initializes with a postal code and a service" do
      finder = described_class.new(postal_code, default_service)
      expect(finder.postal_code).to eq postal_code
      expect(finder.service).to eq default_service
    end

    describe 'attributes' do
      subject(:finder) do
        described_class.new(postal_code, default_service) 
      end

      its(:address) { should be_a Finder::Address }
      its(:service) { should be_a default_service.class }

      it { should_not respond_to :address= }
      it { should_not respond_to :error= }

      it "has a postal_code attr_accessor" do
        finder.postal_code = '11111-111'
        expect(finder.postal_code).to eq '11111-111'
      end

      it "has a service attr_accessor" do
        service = Object.new
        finder.service = service
        expect(finder.service).to eq service
      end
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
          expect(@finder.successful?).to be_nil
        end
      end

      context 'successful find' do
        it 'returns true' do
          expect(service).to receive(:fetch).with(postal_code, @finder.address)
          expect(@finder.find).to be_true
          expect(@finder).to be_successful
          expect(@finder.address).to be_frozen
        end
      end

      context 'unsuccessful find' do
        it 'returns false' do
          message = 'Some error occurred'
          service.stub(:fetch).and_raise(Services::Error.new, message)
          expect(@finder.find).to be_false
          expect(@finder).to_not be_successful
          expect(@finder.error).to eq message
          expect(@finder.address).to be_frozen
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
    %w{postal_code type address number complement district city state}.each do |field|
      expect_it { to respond_to_option field }
    end

    context "with concat_type_to_address enabled" do
      before { Location.configuration.concat_type_to_address = true }

      it "concats when address is specified after type" do
        subject.type    = 'Rua'
        subject.address = 'Walter Figueiredo'
      end

      it "concats when address is specified before type" do
        subject.address = 'Walter Figueiredo'
        subject.type    = 'Rua'
      end

      after(:each) {
        expect(subject.type).to eq 'Rua'
        expect(subject.address).to eq 'Rua Walter Figueiredo'
      }
    end

    context "with concat_type_to_address disabled" do
      before { Location.configuration.concat_type_to_address = false }

      it "does not concat" do
        subject.type    = 'Rua'
        subject.address = 'Walter Figueiredo'

        expect(subject.type).to eq 'Rua'
        expect(subject.address).to eq 'Walter Figueiredo'
      end
    end
  end
end
