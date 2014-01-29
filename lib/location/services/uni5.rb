require 'net/http'
require 'json'

module Location
  module Services
    class Uni5
      FULL_ADDRESS     = '1'
      ONLY_CITY_AND_UF = '2'

      def fetch(postal_code, address)
        @postal_code = postal_code

        http_request do |res|
          address.state    = res['uf']
          address.city     = res['cidade']
          address.district = res['bairro']
          address.type     = res['tipo_logradouro']
          address.address  = res['logradouro']
        end
      end

      def options
        required = { formato: 'json' }
        required[:cep] = @postal_code if defined?(@postal_code)

        Location.configuration.service_options.merge(required).tap do |o|
          raise OptionsError, 'Missing auth option' unless o.has_key? :auth
        end
      end

      private

      def http_request
        response  = Net::HTTP.get_response(uri)

        unless response.code == '200'
          raise Error.new, "Got response #{response.code} for #{@postal_code}"
        end

        yield eval_result(response.body)
      rescue Net::HTTPBadResponse => e
        raise Error.new, 'Got a bad response'
      end

      def eval_result(json)
        result = JSON.parse(json)

        unless success? result['resultado']
          raise Error.new, "Couldn't find address for #{@postal_code}"
        end

        result
      end

      def success?(result)
        [FULL_ADDRESS, ONLY_CITY_AND_UF].include? result
      end

      def uri
        URI('http://webservice.uni5.net/web_cep.php').tap do |uri|
          uri.query = URI.encode_www_form(options)
        end
      end
    end
  end
end
