require 'spec_helper'

module Location
  describe AddressForm do
    before { Location.configuration.default_service = Services::NullService }
    after(:each) { Location.configuration.default_service = Services::NullService }

    describe "#persist!" do
      before do 
        Services::StubbedService.attributes = {
          city:     'Rio de Janeiro',
          state:    'RJ',
          district: 'Copacabana'
        }
        Location.configuration.default_service = Services::StubbedService
      end

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
        expect(address.city_name).to eq('Rio de Janeiro')
        expect(address.state_name).to eq('RJ')
        expect(address.latitude).to eq(0.12345)
        expect(address.longitude).to eq(0.12345)
      end

      describe "normalizable attributes" do
        context "valid normalizable attributes" do
          it "normalizes state attribute" do
            save_addresses_having_normalized_attributes([:state])

            expect(Location::State).to have(1).items
            expect(Location::City).to have(2).items
            expect(Location::District).to have(2).items
            expect(Location::Address).to have(2).items
          end

          it "normalizes state and city attributes" do
            save_addresses_having_normalized_attributes([:state, :city])

            expect(Location::State).to have(1).items
            expect(Location::City).to have(1).items
            expect(Location::District).to have(2).items
            expect(Location::Address).to have(2).items
          end

          it "normalizes state, city and district attributes" do
            save_addresses_having_normalized_attributes([:state, :city, :district])

            expect(Location::State).to have(1).items
            expect(Location::City).to have(1).items
            expect(Location::District).to have(1).items
            expect(Location::Address).to have(2).items
          end

          it "normalizes city and state by default" do
            default_attributes = AddressForm.new.normalized_attributes
            expect(default_attributes).to match_array([:city, :state])
          end
        end

        context "invalid normalizable attributes" do
          it "doesn't normalize *only* state and district attributes" do
            expect { AddressForm.new.normalized_attributes = [:state, :district] }
            .to raise_error(::StandardError, 'Invalid normalizable attributes')
          end

          it "doesn't normalize *only* district attribute" do
            expect { AddressForm.new.normalized_attributes = [:district] }
            .to raise_error(::StandardError, 'Invalid normalizable attributes')
          end
          
          it "doesn't normalize *only* city and district attributes" do
            expect { AddressForm.new.normalized_attributes = [:city, :district] }
            .to raise_error(::StandardError, 'Invalid normalizable attributes')
          end

          it "doesn't normalize *only* city attribute" do
            expect { AddressForm.new.normalized_attributes = [:city] }
            .to raise_error(::StandardError, 'Invalid normalizable attributes')
          end
        end

        def save_addresses_having_normalized_attributes(attrs)
          address1 = AddressForm.new(valid_attributes)
          address2 = AddressForm.new(valid_attributes(address: 'Alt.'))

          [address1, address2].each do |address|
            address.normalized_attributes = attrs
            address.save
          end
        end
      end
    end

    describe "validations" do
      describe "variable presence validations" do
        context "when no presence attributes are specified" do
          it "validates presence of default attributes" do
            expect(build_address).to have_error_message("can't be blank")
              .on_fields([:postal_code, :address, :district, :city, :state])
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

              expect(address).to have_error_message("can't be blank")
                .on_fields([first, second])
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

          expect(address).to have_error_message("Can't find address for 111111111")
            .on_fields(:postal_code)
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
