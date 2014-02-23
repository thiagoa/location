require 'spec_helper'

module Location
  describe Address do
    it { should belong_to(:district) }
    it { should have_one(:city).through(:district) }
    it { should have_one(:state).through(:city) }

    it { should ensure_length_of(:street).is_at_most(150) }
    it { should ensure_length_of(:number).is_at_most(20) }
    it { should ensure_length_of(:complement).is_at_most(40) }
    it { should validate_numericality_of(:latitude) }
    it { should validate_numericality_of(:longitude) }

    it "is polymorphic" do
      address = FactoryGirl.create(:address_from_catalog)
      catalog = address.addressable

      expect(catalog).to be_a Catalog
      expect(catalog.addresses.count).to eq 1
    end

    it "strips non numbers from the postal code" do
      address = FactoryGirl.create(:address, postal_code: '59082-%^U120')
      expect(address.postal_code).to eq '59082120'
    end
  end
end
