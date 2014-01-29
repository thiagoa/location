require 'location/engine' if defined?(Rails)
require 'location/finder'

Dir[File.dirname(__FILE__) + '/location/services/**/*.rb'].each { |f| require f }

module Location
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Configuration
    attr_accessor :default_service
    attr_accessor :service_options
    attr_accessor :concat_type_to_address
    attr_accessor :normalized_fields

    def initialize
      @default_service = Services::Republica
      @service_options = {}
      @concat_type_to_address = false
      @normalized_fields = %i{state city}
    end
  end
end
