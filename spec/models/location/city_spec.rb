require 'spec_helper'

module Location
  describe City do
    it { should belong_to :state }
    it { should have_many :districts }
  end
end
