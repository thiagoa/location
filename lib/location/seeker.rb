module Location
  class AddressData
    attr_accessor :postal_code, :address, :number, :complement, :district, :city, :state
  end

  class AddressException < Exception; end

  class Seeker
    attr_accessor :postal_code, :service, :address, :error

    def initialize(postal_code, service = nil)
      service ||= RepublicaService

      @postal_code = postal_code
      @service     = service
      @address     = AddressData.new
    end

    def fetch
      service.fetch(postal_code, address)
      success = true
    rescue AddressException => e
      error = e.message
      success = false
    ensure
      yield(success, self) if block_given?
    end
  end

  class RepublicaService
    def self.fetch(postal_code, address)
    end
  end
end
