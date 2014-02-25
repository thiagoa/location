require 'spec_helper'

module Location
  describe District do
    it { should belong_to(:city) }
    it { should have_many(:addresses) }
  end
end
