require 'spec_helper'

module Location
  describe City do
    it { should belong_to :state }
  end
end
