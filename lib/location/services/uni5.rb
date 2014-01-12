require 'net/http'
require 'json'

module Location
  module Services
    class Uni5
      URL = 'http://webservice.uni5.net/web_cep.php'

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
          uri       = URI(URL)
          uri.query = URI.encode_www_form(options)
          result    = JSON.parse Net::HTTP.get(uri)

          yield result
        end
    end
  end
end
