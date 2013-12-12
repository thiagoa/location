require 'spec_helper'

module Location
  describe State do
    it { should have_many :cities }
    it { should validate_presence_of :name }
    it { should ensure_length_of(:name).is_at_most(150) }
  end
end
