require 'rails_helper'
RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :invoices }
  end

  describe 'class methods' do
    describe '#search_for_all(string)' do
      it 'returns all merchants where there is a partial match for the query param' do
        merchant1 = Merchant.create!(name: "Turing")
        merchant2 = Merchant.create!(name: "Ring World")
        merchant3 = Merchant.create!(name: "Rose Rings")
        merchant4 = Merchant.create!(name: "XXQQ")

        expect(Merchant.search_for_all("ring")).to eq([merchant2, merchant3, merchant1])
      end

      it 'returns an empty array when no merchant matches are found' do
        merchant1 = Merchant.create!(name: "Turing")
        merchant2 = Merchant.create!(name: "Ring World")
        merchant3 = Merchant.create!(name: "Rose Rings")
        merchant4 = Merchant.create!(name: "XXQQ")

        expect(Merchant.search_for_all("PPP")).to eq([])
      end
    end
  end
end