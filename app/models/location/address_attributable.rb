module Location
  module AddressAttributable
    fields = %i{postal_code street number complement
                district city state latitude longitude}

    fields.each do |field|
      attr_writer field

      define_method field do
        instance_value = instance_variable_get("@#{field}")

        if instance_value.nil? && respond_to?(:address) && !address.nil?
          value = address.send(field)
          value.respond_to?(:name) ? value.name : value
        else
          instance_value
        end
      end
    end
  end
end
