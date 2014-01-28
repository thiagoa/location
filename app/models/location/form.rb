require 'virtus'

module Location
  module Form
    def self.included(klass)
      virtus = @virtus_options ? 
        Virtus.model(@virtus_options) : 
        Virtus.model

      klass.include virtus

      klass.include ActiveModel::Conversion
      klass.include ActiveModel::Validations
      klass.extend  ActiveModel::Naming

      @virtus_options = nil
    end

    def self.base(virtus_options = {})
      @virtus_options = virtus_options
      Form
    end

    def persisted?
      false
    end

    def save
      if valid?
        persist!
        true
      else
        false
      end
    end
  end
end
