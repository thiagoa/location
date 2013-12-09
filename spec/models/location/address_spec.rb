require 'spec_helper'

module Location
  describe Address do
    it { should belong_to(:district) }
  end
end
