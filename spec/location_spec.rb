require 'spec_helper'
require 'location'

module Location
  describe Location do
    describe '#configure' do
      it { should respond_to :configure }
      it 'yields self' do
        expect do |block| 
          described_class.configure(&block)
        end.to yield_with_args described_class
      end
    end

    describe 'config options' do
      its(:default_service) { should be(Services::Republica) }
    end
  end
end
