require 'spec_helper'
require 'location'

module Location
  describe Configuration do
    its(:default_service) { should be(Services::Republica) }

    it 'assigns a default service' do
      service = Object.new
      subject.default_service = service
      expect(subject.default_service).to eq service
    end
  end

  describe Location do
    describe '#configuration' do
      it "returns a Configuration object by default" do
        expect(Location.configuration).to be_instance_of(Configuration)
      end
    end

    describe '#configure' do
      it 'yields a Configuration instance' do
        configuration = Configuration.new
        described_class.configuration = configuration
        expect do |block| 
          described_class.configure(&block)
        end.to yield_with_args configuration
      end
    end
  end
end
