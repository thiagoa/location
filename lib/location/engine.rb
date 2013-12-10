module Location
  class Engine < ::Rails::Engine
    isolate_namespace Location

    config.generators do |g|
      g.test_framework :rspec, view_specs: false, fixture_replacement: :factory_girl
      g.fixture_replacement :factory_girl, dir: 'spec/support/factories'
    end
  end
end
