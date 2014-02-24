require 'spec_helper'
require 'location/finder'
require 'location/services/uni5'
require 'webmock/rspec'

module Location
  describe Services::Uni5 do
    before { Location.configuration.concat_type_to_street = false }

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

      context 'with invalid options' do
        it "raises OptionsError with no auth option" do
          Location.configuration.stub(:service_options).and_return({})
          expect { subject.options }.to \
            raise_error(Services::OptionsError, 'Missing auth option')
        end
      end
    end

    describe '#fetch' do
      def json(cep)
        path = "../../support/fixtures/uni5_#{cep}.json"
        file = File.expand_path(path, __FILE__)
        File.read(file).chomp
      end

      def stub_valid_options
        options = { auth: '12345', formato: 'json', cep: cep }
        subject.stub(:options).and_return(options)
        options
      end

      def stub_http_fetch(cep)
        @stub = stub_request(:get, "http://webservice.uni5.net/web_cep.php").
          with(query: stub_valid_options).
          to_return(body: json(cep))
      end

      context 'with a valid postal code' do
        before do
          stub_http_fetch('59022-120')
          subject.fetch('59022-120', address)
        end

        it "calls http_request" do
          expect(@stub).to have_been_requested
        end

        it "feeds the address object" do
          address.tap do |a|
            expect([a.state, a.city, a.district, a.type, a.street]).
              to eq ['RN', 'Natal', 'Barro Vermelho', 'Rua', 'Doutor José Bezerra']
          end
        end
      end

      context 'with an invalid postal code' do
        it 'raises an Error' do
          stub_http_fetch('1111111')
          expect { subject.fetch('1111111', address) }.
            to raise_error Services::Error, "Couldn't find address for 1111111"
        end

        after { expect(@stub).to have_been_requested }
      end

      context 'when response code is not 200' do
        it 'raises an Error' do
          stub_request(:get, "http://webservice.uni5.net/web_cep.php").
            with(query: stub_valid_options).
            to_return(status: 404)

          expect { subject.fetch('59022-120', address) }.
            to raise_error Services::Error, 'Got response 404 for 59022-120'
        end
      end

      context 'when it returns a bad response' do
        it 'raises an Error' do
          stub_request(:get, "http://webservice.uni5.net/web_cep.php").
            with(query: stub_valid_options).
            to_raise(Net::HTTPBadResponse)

          expect { subject.fetch('59022-120', address) }.
            to raise_error Services::Error, 'Got a bad response'
        end
      end

      context 'when it returns a socket error' do
        it 'raises an Error' do
          stub_request(:get, "http://webservice.uni5.net/web_cep.php").
            with(query: stub_valid_options).
            to_raise(SocketError)

          expect { subject.fetch('59022-120', address) }.
            to raise_error Services::Error, 'Got a socket error'
        end
      end
    end

    describe 'real fetch', external: true do
      it 'fetches the sample content' do
        WebMock.allow_net_connect!
        subject.fetch(cep, address)

        address.tap do |a|
          expect([a.state, a.city, a.district, a.type, a.street]).to eq \
            ['RN', 'Natal', 'Barro Vermelho', 'Rua', 'Doutor José Bezerra']
        end
      end
    end
  end
end
