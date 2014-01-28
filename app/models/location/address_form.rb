module Location
  class AddressForm
    include Form

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

    validate :ensure_find_address

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
        State.send(persist_method(:state), name: state)
          .cities.send(persist_method(:city), name: city)
          .districts.send(persist_method(:districts), name: district)
          .addresses.create!(address_attributes)
      end
    end

    def persist_method(attr)
      attribute_normalizable?(attr) ? "first_or_create!" : "create!"
    end

    def attribute_normalizable?(attr)
      Location.configuration.normalized_fields.include?(attr)
    end

    def ensure_find_address
      Finder.find(postal_code) do |f|
        if f.error
          errors.add :postal_code, %{Can't find address for #{postal_code}}
        end
      end
    end

    def values_for_attributes(attributes)
      attributes.each_with_object({}) do |attr, hash|
        hash[attr] = send(attr)
      end
    end
  end
end
