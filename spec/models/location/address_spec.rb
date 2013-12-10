require 'spec_helper'

module Location
  describe Address do
    it { should belong_to(:district) }

    it "is polymorphic" do
      address = FactoryGirl.create(:address_from_catalog)
      catalog = address.addressable
      expect(catalog).to be_a Catalog
      catalog.addresses.count.should == 1
    end
  end
end
