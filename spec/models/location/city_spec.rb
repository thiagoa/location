require 'spec_helper'

module Location
  describe City do
    it { should belong_to :state }
    it { should have_many :districts }
    it { should accept_nested_attributes_for :state }
    it { should validate_presence_of :name }
    it { should ensure_length_of(:name).is_at_most(150) }
  end
end
