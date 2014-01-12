require 'spec_helper'
require 'location/finder'
require 'location/services/uni5'
require 'webmock/rspec'

module Location
  describe Services::Uni5 do
    before { Location.configuration.concat_type_to_address = false }

    let(:cep)      { '59022-120' }
    let!(:address) { Finder::Address.new }

    describe '#options' do
      it "has the right 'cep' and 'formato' options" do
        Location.configuration.stub(:service_options).and_return(auth: '12345')

        subject.stub(:http_request)
        subject.fetch(cep, address)
        options = subject.options
        
        expect([options[:cep], options[:formato]]).to eq [cep, 'json']
      end
    end

    describe '#fetch' do
      context 'with valid options' do
        let(:json) {
          path = "../../support/fixtures/uni5_#{cep}.json"
          file = File.expand_path(path, __FILE__)
          File.read(file).chomp
        }

        before do
          options = { auth: '12345', formato: 'json', cep: cep }
          subject.stub(:options).and_return(options)

          @stub = stub_request(:get, "http://webservice.uni5.net/web_cep.php").
            with(query: options).
            to_return(body: json)

          subject.fetch(cep, address)
        end

        it "calls http_request" do
          expect(@stub).to have_been_requested
        end

        it "feeds the address object" do
          address.tap do |a|
            expect([a.state, a.city, a.district, a.type, a.address]).to eq \
              ['RN', 'Natal', 'Barro Vermelho', 'Rua', 'Doutor José Bezerra']
          end
        end
      end

      context 'with invalid options' do
        it "fails with no auth option" do
          Location.configuration.stub(:service_options).and_return({})
          expect { subject.fetch(cep, address) }.to \
            raise_error(Services::OptionsError, 'Missing auth option')
        end
      end
    end

    describe 'real fetch', external: true do
      it 'fetches the sample content' do
        WebMock.allow_net_connect!
        subject.fetch(cep, address)

        address.tap do |a|
          expect([a.state, a.city, a.district, a.type, a.address]).to eq \
            ['RN', 'Natal', 'Barro Vermelho', 'Rua', 'Doutor José Bezerra']
        end
      end
    end
  end
end
