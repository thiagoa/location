require 'spec_helper'

module Location
  describe State do
    it { should have_many :cities }
    it { should have_many(:districts).through(:cities) }
    it { should have_many(:addresses).through(:districts) }

    it { should ensure_length_of(:name).is_at_most(150) }
  end
end
