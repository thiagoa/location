require 'super_form'
require 'active_support/concern'
require 'location/address_validations'

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

  class AddressPersister
    def initialize(normalizer, address)
      @normalizer = normalizer
      @address = address
    end

    def persist!
      State.transaction(requires_new: true) do
        if @address && @address.persisted?
          update
        else
          create
        end
      end
    end

    private

    def create
      state    = create_attribute(:state, State)
      city     = create_attribute(:city, state.cities.build)
      district = create_attribute(:district, city.districts.build)

      @address = district.addresses.create!(@normalizer.attributes)
      @normalizer.address = @address
    end

    def create_attribute(attribute, object)
      object = object.new if object.is_a?(Class)
      attributes = @normalizer.parameterize_attribute(attribute)

      object.find_or_save!(attributes)
    end

    def update
      @address.update(@normalizer.attributes)

      district = update_attribute(@address, :district)
      city     = update_attribute(district, :city)

      update_attribute(city, :state)
    end

    def update_attribute(parent, attr)
      child = parent.send(attr) || parent.send("build_#{attr.to_s}")
      attributes = @normalizer.parameterize_attribute(attr)
      child.update(attributes)
      child
    end
  end

  module AddressNormalizable
    extend ActiveSupport::Concern

    included do
      before_save :normalize_attributes!
    end

    def normalizable_address_attributes=(attributes)
      current_normalizer.normalizable = attributes
    end

    private

    def current_normalizer
      (@normalizers ||= {})[postal_code] ||= AddressNormalizer.new(self)
    end

    def normalize_attributes!
      unless current_normalizer.normalize!
        errors.add :postal_code, %{Can't find address for #{postal_code}}
        false
      end
    end
  end

  class AddressForm
    include SuperForm
    include AddressValidations
    include AddressNormalizable

    def self.default_presence_attributes
      %i{postal_code street district}
    end

    def self.string_attributes
      %i{postal_code street number complement district city state}
    end

    def self.float_attributes
      %i{latitude longitude}
    end

    string_attributes.each { |attr| field attr, Field::Text }
    float_attributes.each  { |attr| field attr, Field::Float }

    (string_attributes + float_attributes).each do |attr|
      validates attr, presence: true, if: ->(a){ a.presence[attr] }
    end

    attr_accessor :address

    def presence
      @presence || validate_presence_of(AddressForm.default_presence_attributes)
    end

    def validate_presence_of(attributes)
      attributes = Array(attributes)

      @presence = self.attributes.keys.inject({}) do |hash, attr|
        hash[attr] = attributes.include?(attr)
        hash
      end
    end

    private

    def persist!
      AddressPersister.new(current_normalizer, address).persist!
    end
  end
end
