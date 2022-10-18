require 'rails_helper'
RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'class methods' do
    describe '#find_matching_item' do
      it 'return the item which has the best match to a given query param' do
        merchant1 = create(:merchant)
        merchant2 = create(:merchant)
    
        item2 = Item.create!(name: "Bracelet", description: "Cool and nice", unit_price: 900, merchant_id: merchant2.id)
        item3 = Item.create!(name: "Jewelery Earrings", description: "Pretty", unit_price: 800, merchant_id: merchant1.id)
        item1 = Item.create!(name: "Earrings", description: "Pretty", unit_price: 888, merchant_id: merchant1.id)
        item4 = Item.create!(name: "Shoes", description: "Nice Shoes", unit_price: 8, merchant_id: merchant1.id)
        item5 = Item.create!(name: "Plates", description: "plates are cool", unit_price: 88888, merchant_id: merchant2.id)

        expect(Item.find_matching_item("ring")).to eq(item1)
      end
    end
  end
  
end