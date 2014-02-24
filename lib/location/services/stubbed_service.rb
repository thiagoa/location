module Location
  module Services
    class StubbedService
      def self.attributes
        @attributes ||= {}
      end

      def self.set_result(postal_code, attributes)
        self.attributes[postal_code] ||= attributes
      end

      def self.attributes_for(postal_code)
        self.attributes[postal_code] || {}
      end

      def fetch(postal_code, address)
        self.class.attributes_for(postal_code).each do |k, v|
          address.send("#{k}=", v)
        end
      end
    end
  end
end
