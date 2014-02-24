module Location
  module FindOrCreate
    def find_or_save!(attributes)
      attributes = self.attributes.select { |k| k =~ /_id$/ }
        .merge(attributes)

      if attributes[:normalized]
        object = self.class.find_by(attributes)
      end

      if object
        object
      else
        self.attributes = attributes
        save!
        self
      end
    end
  end
end
