require 'spec_helper'

module Location
  describe State do
    it { should have_many :cities }
    it { should have_many(:districts).through(:cities) }
    it { should have_many(:addresses).through(:districts) }
  end
end
