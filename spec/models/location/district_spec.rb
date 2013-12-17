require 'spec_helper'

module Location
  describe District do
    it { should belong_to(:city) }
    it { should have_many(:addresses) }
    it { should accept_nested_attributes_for(:city) }
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(150) }
  end
end
