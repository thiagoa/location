require 'super_form'

module Location
  class AddressNormalizer
    def self.normalizable
      %i{state city district}
    end

    attr_reader :finder

    def initialize(postal_code, model)
      @finder = Finder.build(postal_code)
      @model = model
    end

    def finder_successful?
      trigger_find
      @finder.successful?
    end

    def normalize!
      if finder_successful?
        normalizable.each do |a|
          @model.send("#{a}=", @finder.address.send(a))
        end
      end
    end

    def normalizable=(attributes)
      @normalizable = Array(attributes)
      ensure_valid_normalizable!
    end

    def normalizable
      @normalizable ||= Location.configuration.normalized_fields
      ensure_valid_normalizable!
      @normalizable
    end

    def normalizable?(attribute)
      normalizable.include?(attribute)
    end

    private

    def trigger_find
      return if @ok
      @ok = @finder.find
    end

    def ensure_valid_normalizable!
      unless valid_normalizable?
        raise ::StandardError.new, "Invalid normalizable attributes"
      end
    end

    def valid_normalizable?
      valid = self.class.normalizable.slice(0, @normalizable.count)
      valid == @normalizable || valid.reverse == @normalizable
    end
  end

  module AddressNormalizable
    def self.included(base)
      base.before_validation :build_address_normalizer
      base.validate :ensure_find_address
      base.before_save :normalize_address_attributes!
    end

    def build_address_normalizer
      @normalizer ||= AddressNormalizer.new(postal_code, self)
    end

    def ensure_find_address
      unless @normalizer.finder_successful?
        errors.add :postal_code, %{Can't find address for #{postal_code}}
      end
    end

    def normalize_address_attributes!
      @normalizer.normalize!
    end

    def normalizable_address_attributes=(attributes)
      build_address_normalizer.normalizable = attributes
    end
  end

  class AddressForm
    include SuperForm
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

    attr_accessor :model

    def presence
      @presence || validate_presence_of(AddressForm.default_presence_attributes)
    end

    def address_attributes
      attributes = %w{postal_code street number complement latitude longitude}
      values_for_attributes(attributes)
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
      State.transaction(requires_new: true) do
        if @model.try(:persisted?)
          update
        else
          create
        end
      end
    end

    def create
      state    = create_attribute(:state, State)
      city     = create_attribute(:city, state.cities)
      district = create_attribute(:district, city.districts)

      @model = district.addresses.create!(address_attributes)
    end

    def update
      @model.update(address_attributes)

      district = update_attribute(@model, :district)
      city     = update_attribute(district, :city)

      update_attribute(city, :state)
    end

    def update_attribute(parent, attr)
      child = parent.send(attr) || parent.send("build_#{attr.to_s}")
      child.update(attributes_for(attr))
      child
    end

    def attributes_for(attr)
      { name: send(attr), normalized: @normalizer.normalizable?(attr) }
    end

    def create_attribute(attr, klass)
      attrs  = attributes_for(attr)
      method = attrs[:normalized] ? "first_or_create!" : "create!"
      klass.send(method, attrs)
    end

    def values_for_attributes(attributes)
      attributes.each_with_object({}) do |attr, hash|
        hash[attr] = send(attr)
      end
    end
  end
end
