require 'spec_helper'

module Location
  describe Address do
    it { should belong_to(:district) }
    it { should belong_to(:city) }
    it { should belong_to(:state) }
  end
end
