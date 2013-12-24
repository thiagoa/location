module Location
  class Finder
    attr_accessor :postal_code, :service, :address, :error

    def self.build(postal_code)
      new(postal_code, RepublicaService.new)
    end

    def initialize(postal_code, service)
      @postal_code = postal_code
      @service     = service
      @address     = Address.new
    end

    def success?
      @success
    end

    def find
      service.fetch(postal_code, address)
      @success = true
    rescue ServiceException => e
      error = e.message
      @success = false
    ensure
      yield(self) if block_given?
    end

    class Address
      attr_accessor :postal_code, :address, :number, :complement, :district, :city, :state
    end
  end

  class ServiceException < Exception; end

  class RepublicaService
    def fetch(postal_code, address)
    end
  end
end
