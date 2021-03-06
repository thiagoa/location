require 'spec_helper'

module Location
  describe Address do
    it { should belong_to(:district) }
    it { should have_one(:city).through(:district) }
    it { should have_one(:state).through(:city) }

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
