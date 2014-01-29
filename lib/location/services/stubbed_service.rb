module Location
  module Services
    class StubbedService
      class << self
        attr_writer :attributes
      end

      def self.attributes
        @attributes || {
          address:    'R. Barata Ribeiro',
          number:     '1981',
          complement: '',
          district:   'Copacabana',
          city:       'Rio de Janeiro',
          state:      'RJ'
        }
      end

      def fetch(postal_code, address)
        StubbedService.attributes.each do |k, v|
          address.send("#{k}=", v)
        end
      end
    end
  end
end
