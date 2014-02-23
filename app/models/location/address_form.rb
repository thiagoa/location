require 'super_form'

module Location
  module AddressNormalizable
    def self.included(base)
      base.extend ClassMethods

      base.before_validation :build_finder
      base.validate :ensure_find_address
      base.before_save :normalize_attributes!
    end

    def build_finder
      @finder = Finder.build(postal_code)
    end

    def ensure_find_address
      @finder.find do |f|
        unless f.successful?
          errors.add :postal_code, %{Can't find address for #{postal_code}}
        end
      end
    end

    def normalize_attributes!
      normalized_attributes.each do |f|
        send("#{f}=", @finder.address.send(f))
      end
    end

    def normalized_attributes=(attributes)
      @normalized_attributes = Array(attributes)
      ensure_valid_normalized_attributes!
    end

    def normalized_attributes
      @normalized_attributes ||= Location.configuration.normalized_fields
      ensure_valid_normalized_attributes!
      @normalized_attributes
    end

    def ensure_valid_normalized_attributes!
      unless valid_normalized_attributes?
        raise ::StandardError.new, "Invalid normalizable attributes"
      end
    end

    def attribute_normalized?(attr)
      normalized_attributes.include?(attr)
    end

    private

    def valid_normalized_attributes?
      valid = self.class.normalizable_attributes.slice(0, @normalized_attributes.count)
      valid == @normalized_attributes || valid.reverse == @normalized_attributes
    end

    module ClassMethods
      def normalizable_attributes
        %i{state city district}
      end
    end
  end
  class AddressForm
    include SuperForm
    include AddressNormalizable

    def self.default_presence_attributes
      %i{postal_code address district}
    end

    def self.string_attributes
      %i{postal_code address number complement district city state}
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
      attributes = %w{postal_code address number complement latitude longitude}
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
      { name: send(attr), normalized: attribute_normalized?(attr) }
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
