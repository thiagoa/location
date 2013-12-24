require 'location/engine' if defined?(Rails)
require 'location/finder'

Dir[File.dirname(__FILE__) + '/location/services/**/*.rb'].each { |f| require f }

module Location
  class << self
    def configure
      yield self
    end

    attr_accessor :default_service
  end

  self.default_service = Services::Republica
end
