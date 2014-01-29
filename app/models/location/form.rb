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
      klass.extend  ActiveModel::Callbacks

      add_callbacks(klass)

      @virtus_options = nil
    end

    def self.add_callbacks(klass)
      klass.class_eval do
        alias_method :ar_valid?, :valid?

        def valid?
          run_callbacks :validation do
            ar_valid?
          end
        end

        define_model_callbacks :validation, :save
      end
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
        run_callbacks :save do
          persist!
        end
        true
      else
        false
      end
    end
  end
end
