module Location
  module Services
    class FailedService
      def fetch(postal_code, address)
        raise Error.new
      end
    end
  end
end
