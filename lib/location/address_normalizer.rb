require 'delegate'
require 'location/finder'

module Location
  class AddressNormalizer
    extend Forwardable

    def self.allowed_for_normalization
      %i{state city district}
    end

    def self.default_normalizable
      Location.configuration.normalizable_attributes
    end

    attr_reader :model
    def_delegators :model, :address, :address=

    def initialize(model)
      @model = model
    end

    def normalize!
      Finder.find(@model.postal_code) do |finder|
        return false unless finder.successful?

        normalizable.each do |a|
          value = finder.address.send(a)
          @model.send("#{a}=", value) unless value.nil?
        end
      end
    end

    def normalizable=(attributes)
      @normalizable = Array(attributes)
      ensure_valid_normalizable!
    end

    def normalizable
      @normalizable ||= self.class.default_normalizable
      ensure_valid_normalizable!

      @normalizable
    end

    def normalizable?(attribute)
      normalizable.include?(attribute)
    end

    def attributes
      attributes = %w{postal_code street number complement latitude longitude}

      attributes.each_with_object({}) do |attr, hash|
        hash[attr] = @model.send(attr)
      end
    end

    def parameterize_attribute(attribute)
      {
        name: @model.send(attribute),
        normalized: normalizable?(attribute)
      }
    end

    private

    def ensure_valid_normalizable!
      unless valid_normalizable?
        raise ::StandardError.new, "Invalid normalizable attributes"
      end
    end

    def valid_normalizable?
      valid = self.class.allowed_for_normalization.slice(0, @normalizable.count)
      valid == @normalizable || valid.reverse == @normalizable
    end
  end
end
