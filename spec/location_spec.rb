require 'spec_helper'
require 'location'

module Location
  describe Configuration do
    expect_it { to respond_to_option(:service_options).with_value({}) }
    expect_it { to respond_to_option(:default_service).with_value(Services::Republica) }
    expect_it { to respond_to_option(:concat_type_to_street).with_value(false) }
    expect_it { to respond_to_option(:normalized_fields).with_value(%i{state city}) }
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
