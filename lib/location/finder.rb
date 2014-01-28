module Location
  class Finder
    attr_accessor :postal_code, :service
    attr_reader   :address, :error

    def self.build(postal_code)
      new(postal_code, Location.configuration.default_service.new)
    end

    def self.find(postal_code, &block)
      build(postal_code).find(&block)
    end

    def initialize(postal_code, service)
      @postal_code = postal_code
      @service     = service
      @address     = Address.new
    end

    def successful?
      @success
    end

    def find
      service.fetch(postal_code, address)
      @success = true
    rescue Services::Error => e
      @error = e.message
      @success = false
    ensure
      @address.freeze
      yield(self) if block_given?
    end

    class Address
      attr_accessor :type, :postal_code, :address, :number
      attr_accessor :complement, :district, :city, :state

      def type=(type)
        @type = type
        concat_type_to_address! if concat_type_to_address?
      end

      def address=(address)
        @address = address
        concat_type_to_address! if concat_type_to_address?
      end

      private
        def concat_type_to_address?
          Location.configuration.concat_type_to_address && type && address
        end

        def concat_type_to_address!
          @address = "#{type} #{address}"
        end
    end
  end
end
