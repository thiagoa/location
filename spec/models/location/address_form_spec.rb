require 'spec_helper'

module Location
  describe AddressForm do
    before { Location.configuration.default_service = Services::NullService }

    describe "#persist!" do
      it "saves address data to the database" do
        build_valid_address.save

        address = Location::Address.joins(:district).joins(:city).joins(:state).
          select(%q{
            location_addresses.*,
            location_districts.name as district_name,
            location_cities.name as city_name,
            location_states.name as state_name
          }).first

        expect(address.postal_code).to eq('59022120')
        expect(address.address).to eq('R. Doutor José Bezerra')
        expect(address.number).to eq('1981')
        expect(address.complement).to eq('Bl. 13')
        expect(address.district_name).to eq('Barro Vermelho')
        expect(address.city_name).to eq('Natal')
        expect(address.state_name).to eq('RN')
        expect(address.latitude).to eq(0.12345)
        expect(address.longitude).to eq(0.12345)
      end

      it "normalizes city and state" do
        build_valid_address.save
        build_valid_address(address: 'Alt.').save

        expect(Location::City.count).to eq(1)
        expect(Location::State.count).to eq(1)
        expect(Location::District.count).to eq(2)
        expect(Location::Address.count).to eq(2)
      end
    end

    describe "validations" do
      describe "variable presence validations" do
        context "when no presence attributes are specified" do
          it "validates presence of default attributes" do
            expect(build_address).to have_error_message("can't be blank").
              on_fields([:postal_code, :address, :district, :city, :state])
          end
        end

        context "when one presence attribute is specified" do
          it "validates presence of one attribute" do
            AddressForm.new.attributes.keys.each do |field|
              address = build_address { |address| address.validate_presence_of(field) }
              expect(address).to have_error_message("can't be blank").on_fields(field)
            end
          end
        end

        context "when two presence attributes are specified" do
          it "validates presence of two attributes" do
            AddressForm.new.attributes.keys.each_slice(2) do |first, second|
              break if second.nil?

              address = build_address do |address|
                address.validate_presence_of([first, second])
              end

              expect(address).to have_error_message("can't be blank").
                on_fields([first, second])
            end
          end
        end
      end

      describe "postal code webservice validation" do
        it "is valid with a valid postal code" do
          address = build_valid_address(postal_code: '59022-120')
          expect(address.errors).to be_empty
        end

        it "is invalid with an invalid postal code" do
          Location.configuration.default_service = Services::FailedService
          address = build_address(valid_attributes(postal_code: '111111111'))
          address.save

          expect(address).to have_error_message("Can't find address for 111111111").
            on_fields(:postal_code)
        end
      end
    end

    def valid_attributes(extra = {})
      {
        postal_code: '59022-120',
        address:     'R. Doutor José Bezerra',
        number:      '1981',
        complement:  'Bl. 13',
        district:    'Barro Vermelho',
        city:        'Natal',
        state:       'RN',
        latitude:    0.12345,
        longitude:   0.12345,
      }.merge(extra)
    end

    def build_address(attributes = {})
      address = AddressForm.new(attributes)
      yield address if block_given?
      address.valid?
      address
    end

    def build_valid_address(extra = {}, &block)
      build_address(valid_attributes(extra, &block))
    end
  end
end
