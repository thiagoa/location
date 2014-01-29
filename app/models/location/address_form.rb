module Location
  class AddressForm
    include Form

    def self.normalizable_attributes
      %i{state city district}
    end

    def self.default_presence_attributes
      %i{postal_code address district city state}
    end

    def self.string_attributes
      %i{postal_code address number complement district city state}
    end

    def self.float_attributes
      %i{latitude longitude}
    end

    string_attributes.each { |attr| attribute attr, String }
    float_attributes.each  { |attr| attribute attr, Float  }

    (string_attributes + float_attributes).each do |attr|
      validates attr, presence: true, if: ->(a){ a.presence[attr] }
    end

    before_validation :build_finder
    validate          :ensure_find_address
    before_save       :normalize_attributes!

    attr_reader :normalized_attributes

    def initialize(*args)
      super
      self.normalized_attributes = Location.configuration.normalized_fields
    end

    def presence
      @presence || validate_presence_of(AddressForm.default_presence_attributes)
    end

    def address_attributes
      attributes = %w{postal_code address number complement latitude longitude}
      values_for_attributes(attributes)
    end

    def normalized_attributes=(attributes)
      @normalized_attributes = Array(attributes)

      unless valid_normalized_attributes?
        raise ::StandardError.new, "Invalid normalizable attributes"
      end
    end

    def attribute_normalized?(attr)
      normalized_attributes.include?(attr)
    end

    def validate_presence_of(attributes)
      attributes = Array(attributes)
      @presence = self.attributes.keys.inject({}) do |hash, attr|
        hash[attr] = attributes.include?(attr)
        hash
      end
    end

    private

    def valid_normalized_attributes?
      valid = self.class.normalizable_attributes.slice(0, normalized_attributes.count)
      valid == normalized_attributes || valid.reverse == normalized_attributes
    end

    def persist!
      State.transaction(requires_new: true) do
        state    = save_attribute(:state,    State)
        city     = save_attribute(:city,     state.cities)
        district = save_attribute(:district, city.districts)

        district.addresses.create!(address_attributes)
      end
    end

    def save_attribute(attr, klass)
      attrs  = { name: send(attr), normalized: attribute_normalized?(attr) }
      method = attrs[:normalized] ? "first_or_create!" : "create!"

      klass.send(method, attrs)
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

    def values_for_attributes(attributes)
      attributes.each_with_object({}) do |attr, hash|
        hash[attr] = send(attr)
      end
    end
  end
end
