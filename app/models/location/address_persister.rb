module Location
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
      state    = create_attribute(:state, State.new)
      city     = create_attribute(:city, state.cities.build)
      district = create_attribute(:district, city.districts.build)

      @address = district.addresses.create!(@normalizer.attributes)
      @normalizer.address = @address
    end

    def create_attribute(attribute, object)
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
end
