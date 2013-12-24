module Location
  class Finder
    attr_accessor :postal_code, :service
    attr_reader   :address, :error

    def self.build(postal_code)
      new(postal_code, Location.configuration.default_service.new)
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
      attr_accessor :postal_code, :address, :number, :complement, :district, :city, :state
    end
  end
end
