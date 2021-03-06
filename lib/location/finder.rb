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
      @service = service
      @address = Address.new
    end

    def find
      service.fetch(postal_code, address)
      @success = true
    rescue Services::Error => error
      @error   = error.message
      @success = false
    ensure
      @address.freeze
      yield self if block_given?
    end

    def successful?
      @success
    end

    class Address
      attr_accessor :type, :postal_code
      attr_accessor :street, :number, :complement
      attr_accessor :district, :city, :state

      def type=(type)
        @type = type
        concat_type_to_street
      end

      def street=(street)
        @street = street
        concat_type_to_street
      end

      def to_hash(options = {})
        attributes = instance_variables.map do |k|
          k.to_s.gsub(/^@/, '').to_sym
        end

        only = Array(options[:only] || attributes).map!(&:to_sym)

        attributes.each_with_object({}) do |k, a|
          a[k] = send(k) if only.include?(k)
        end
      end

      private

      def concat_type_to_street
        concat_type_to_street! if concat_type_to_street?
      end

      def concat_type_to_street?
        Location.configuration.concat_type_to_street &&
          !type.nil? && !street.nil?
      end

      def concat_type_to_street!
        @street = "#{type} #{street}"
      end
    end
  end
end
