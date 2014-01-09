require 'location/engine' if defined?(Rails)
require 'location/finder'

Dir[File.dirname(__FILE__) + '/location/services/**/*.rb'].each { |f| require f }

module Location
  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end

  class Configuration
    attr_accessor :default_service
    attr_accessor :service_options

    def initialize
      @default_service = Services::Republica
      @service_options = {}
    end
  end
end
