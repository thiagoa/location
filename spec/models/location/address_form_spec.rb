require 'spec_helper'

module Location
  describe AddressForm do
    before(:each) { Location.configuration.default_service = Services::NullService }

    describe "#persist!" do
      context 'with one postal code' do
        before do
          Services::StubbedService.set_result('59022-120', {
            city:     'Rio de Janeiro',
            state:    'RJ',
            district: 'Copacabana'
          })

          Location.configuration.default_service = Services::StubbedService

          @valid_address = build_valid_address
          @valid_address.save
        end

        it "saves address data to the database" do
          address = Location::Address.full.first

          expect(address.postal_code).to eq('59022120')
          expect(address.number).to eq('1981')
          expect(address.street).to eq('R. Doutor José Bezerra')
          expect(address.complement).to eq('Bl. 13')
          expect(address.district.name).to eq('Barro Vermelho')
          expect(address.city.name).to eq('Rio de Janeiro')
          expect(address.state.name).to eq('RJ')
          expect(address.latitude).to eq(0.12345)
          expect(address.longitude).to eq(0.12345)
        end

        context "with the same normalization config for the models" do
          it "normalizes state and city by default" do
            other_address = build_valid_address
            other_address.save

            expect_normalized_attributes %i{state city}
          end
        end

        context "with different normalization config for the models" do
          it "normalizes or duplicates the data per-model, as told to" do
            other_address = build_valid_address
            other_address.save

            third_address = build_valid_address
            third_address.normalizable_address_attributes = [:state]
            third_address.save

            expect(Location::State).to have(1).items
            expect(Location::City).to have(2).items
            expect(Location::District).to have(3).items
            expect(Location::Address).to have(3).items
          end
        end

        context "form update" do
          it "updates the underlying models" do
            model         = @valid_address.model
            address       = build_valid_address
            address.model = model

            address.street = 'Nicaragua Street'
            address.number = '54'
            address.save

            last_address = Location::Address.last

            expect(Location::Address.count).to eq 1
            expect(last_address.id).to eq model.id
            expect(last_address.street).to eq 'Nicaragua Street'
            expect(last_address.number).to eq '54'
          end
        end
      end

      context 'with two postal codes' do
        before do
          Location.configuration.default_service = Services::StubbedService

          Services::StubbedService.set_result('59022-120', {
            city: 'Rio de Janeiro',
            state: 'RJ',
          })

          Services::StubbedService.set_result('22222-222', {
            city: 'Natal',
            state: 'RN',
          })
        end

        context 'with two different objects' do
          it "saves distinct normalizations" do
            address = build_valid_address(postal_code: '59022-120')
            address.save

            address = build_valid_address(postal_code: '22222-222')
            address.save

            addresses = Location::Address.full

            expect(Location::Address.count).to eq 2

            expect(addresses.first.state.name).to eq 'RJ'
            expect(addresses.first.city.name).to eq 'Rio de Janeiro'

            expect(addresses.last.city.name).to eq 'Natal'
            expect(addresses.last.state.name).to eq 'RN'
          end
        end

        context 'with the same object' do
          it 'saves distinct normalizations' do
            model = build_valid_address(postal_code: '59022-120')
            model.save

            address = Location::Address.full.first

            expect(address.state.name).to eq 'RJ'
            expect(address.city.name).to eq 'Rio de Janeiro'

            model.postal_code = '22222-222'
            model.save

            expect(Location::Address.count).to eq 1

            address = Location::Address.full.first

            expect(address.state.name).to eq 'RN'
            expect(address.city.name).to eq 'Natal'
          end
        end
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
          expect { AddressForm.new.normalizable_address_attributes = [:state, :district] }
          .to raise_error(::StandardError, 'Invalid normalizable attributes')
        end

        it "doesn't accept *only* district for normalization" do
          expect { AddressForm.new.normalizable_address_attributes = [:district] }
          .to raise_error(::StandardError, 'Invalid normalizable attributes')
        end

        it "doesn't accept *only* city and district for normalization" do
          expect { AddressForm.new.normalizable_address_attributes = [:city, :district] }
          .to raise_error(::StandardError, 'Invalid normalizable attributes')
        end

        it "doesn't accept *only* city for normalization" do
          expect { AddressForm.new.normalizable_address_attributes = [:city] }
          .to raise_error(::StandardError, 'Invalid normalizable attributes')
        end
      end

      def save_addresses
        address1 = AddressForm.new(valid_attributes)
        address2 = AddressForm.new(valid_attributes(street: 'Alt.'))

        [address1, address2].each do |address|
          yield address if block_given?
          address.save
        end
      end

      def save_addresses_having_normalized_attributes(attrs)
        save_addresses do |address|
          address.normalizable_address_attributes = attrs
        end
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
              .on_fields([:postal_code, :street, :district])
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
        street:      'R. Doutor José Bezerra',
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
