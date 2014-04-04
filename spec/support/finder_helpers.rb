module FinderHelpers
  def stub_finder
    @default_service = Location.configuration.default_service

    Location::Services::StubbedService.set_result('59000-001', {
      city: 'Natal',
      state: 'RN',
      district: 'Ponta Negra'
    })

    Location::Services::StubbedService.set_result('59001-002', {
      city: 'Parnamirim',
      state: 'RN',
      district: 'Centro'
    })

    Location.configuration.default_service = Location::Services::StubbedService
  end

  def unstub_finder
    if @default_service
      Location.configuration.default_service = @default_service
      @default_service = nil
    end
  end
end
