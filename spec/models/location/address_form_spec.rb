require 'spec_helper'

module Location
  describe AddressForm do
    before(:each) { Location.configuration.default_service = Services::NullService }

    describe "#persist!" do
      before do 
        Services::StubbedService.attributes = {
          city:     'Rio de Janeiro',
          state:    'RJ',
          district: 'Copacabana'
        }
        Location.configuration.default_service = Services::StubbedService
        build_valid_address.save
      end

      it "saves address data to the database" do
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

      it "normalizes state and city by default" do
        other_address = build_valid_address
        other_address.save

        expect_normalized_attributes %i{state city}
      end
    end

    describe "normalizable attributes" do
      context "with no attributes" do
        before { @normalized_fields = Location.configuration.normalized_fields }
        after  { Location.configuration.normalized_fields = @normalized_fields }

        it "normalizes whatever is specified in the configuration" do
          Location.configuration.normalized_fields = %i{state city district}
          save_addresses
          expect_normalized_attributes %i{state city district}
        end
      end

      context "with valid attributes" do
        it "normalizes :state attribute" do
          save_addresses_having_normalized_attributes %i{state}
          expect_normalized_attributes %i{state}
        end

        it "normalizes :state and :city attributes" do
          save_addresses_having_normalized_attributes %i{state city}
          expect_normalized_attributes %i{state city}
        end

        it "normalizes :state, :city and :district attributes" do
          save_addresses_having_normalized_attributes %i{state city district}
          expect_normalized_attributes %i{state city district}
        end
      end

      context "with invalid attributes" do
        it "doesn't accept *only* state and district for normalization" do
          expect { AddressForm.new.normalized_attributes = [:state, :district] }
          .to raise_error(::StandardError, 'Invalid normalizable attributes')
        end

        it "doesn't accept *only* district for normalization" do
          expect { AddressForm.new.normalized_attributes = [:district] }
          .to raise_error(::StandardError, 'Invalid normalizable attributes')
        end
        
        it "doesn't accept *only* city and district for normalization" do
          expect { AddressForm.new.normalized_attributes = [:city, :district] }
          .to raise_error(::StandardError, 'Invalid normalizable attributes')
        end

        it "doesn't accept *only* city for normalization" do
          expect { AddressForm.new.normalized_attributes = [:city] }
          .to raise_error(::StandardError, 'Invalid normalizable attributes')
        end
      end

      def save_addresses
        address1 = AddressForm.new(valid_attributes)
        address2 = AddressForm.new(valid_attributes(address: 'Alt.'))

        [address1, address2].each do |address|
          yield address if block_given?
          address.save
        end
      end

      def save_addresses_having_normalized_attributes(attrs)
        save_addresses { |address| address.normalized_attributes = attrs }
      end
    end

    def expect_normalized_attributes(attrs)
      %i{state city district}.each do |attr|
        klass = "Location::#{attr.to_s.capitalize}".constantize
        n = attrs.include?(attr) ? 1 : 2
        expect(klass).to have(n).items
      end
    end

    describe "validations" do
      describe "variable presence validations" do
        context "when no presence attributes are specified" do
          it "validates presence of default attributes" do
            expect(build_and_validate_address).to have_error_message("can't be blank")
              .on_fields([:postal_code, :address, :district, :city, :state])
          end
        end

        context "when one presence attribute is specified" do
          it "validates presence of one attribute" do
            AddressForm.new.attributes.keys.each do |field|
              address = build_and_validate_address { |address| address.validate_presence_of(field) }
              expect(address).to have_error_message("can't be blank").on_fields(field)
            end
          end
        end

        context "when two presence attributes are specified" do
          it "validates presence of two attributes" do
            AddressForm.new.attributes.keys.each_slice(2) do |first, second|
              break if second.nil?

              address = build_and_validate_address do |address|
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
          address = build_and_validate_valid_address(postal_code: '59022-120')
          expect(address.errors).to be_empty
        end

        it "is invalid with an invalid postal code" do
          Location.configuration.default_service = Services::FailedService
          address = build_and_validate_address(valid_attributes(postal_code: '111111111'))
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
      address
    end

    def build_and_validate_address(attributes = {}, &block)
      address = build_address(attributes, &block)
      address.valid?
      address
    end

    def build_valid_address(extra = {}, &block)
      build_address(valid_attributes(extra, &block))
    end

    def build_and_validate_valid_address(extra = {}, &block)
      build_and_validate_address(valid_attributes(extra, &block))
    end
  end
end
