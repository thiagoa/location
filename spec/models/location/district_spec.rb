require 'spec_helper'

module Location
  describe District do
    it { should belong_to(:city) }
  end
end
