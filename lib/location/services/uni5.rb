require 'net/http'
require 'json'

module Location
  module Services
    class Uni5
      SUCCESS_FULL_ADDRESS     = '1'
      SUCCESS_ONLY_CITY_AND_UF = '2'

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
        def success?(result)
          [SUCCESS_FULL_ADDRESS, SUCCESS_ONLY_CITY_AND_UF].include? result
        end

        def eval_result(json)
          result = JSON.parse(json)

          if success?(result['resultado'])
            result
          else
            raise Error.new, %{Couldn't find address for #{@postal_code}}
          end
        end

        def uri
          URI('http://webservice.uni5.net/web_cep.php').tap do |uri|
            uri.query = URI.encode_www_form(options)
          end
        end

        def http_request
          response  = Net::HTTP.get_response(uri)

          if response.code == '200'
            yield eval_result(response.body)
          else
            raise Error.new, %{Got response #{response.code} for #{@postal_code}}
          end
        rescue Net::HTTPBadResponse => e
          raise Error.new, %{Got a bad response}
        end
    end
  end
end
