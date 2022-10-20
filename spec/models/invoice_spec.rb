require 'rails_helper'
RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it { should belong_to(:customer) }
    it { should belong_to(:merchant) }
    it { should have_many :transactions }
    it { should have_many :invoice_items }
    it { should have_many(:items).through(:invoice_items) }
  end

  it 'can delete invoices when they have no invoice_items on them' do
    merchant = Merchant.create!(name: Faker::Company.name)

    item1 = Item.create!(name: Faker::Company.name, description: Faker::Lorem.sentence, unit_price: 100, merchant_id: merchant.id )
    item2 = Item.create!(name: Faker::Company.name, description: Faker::Lorem.sentence, unit_price: 40, merchant_id: merchant.id )
    item3 = Item.create!(name: Faker::Company.name, description: Faker::Lorem.sentence, unit_price: 40, merchant_id: merchant.id )

    customer = Customer.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)

    invoice1 = Invoice.create!(status: "completed", customer_id: customer.id, merchant_id: merchant.id)
    invoice2 = Invoice.create!(status: "completed", customer_id: customer.id, merchant_id: merchant.id)
    invoice3 = Invoice.create!(status: "completed", customer_id: customer.id, merchant_id: merchant.id)
    invoice4 = Invoice.create!(status: "completed", customer_id: customer.id, merchant_id: merchant.id)

    invoice_item1 = InvoiceItem.create!(quantity: 4, unit_price: 75, item_id: item1.id, invoice_id: invoice1.id)
    invoice_item2 = InvoiceItem.create!(quantity: 4, unit_price: 75, item_id: item2.id, invoice_id: invoice1.id)
    invoice_item3 = InvoiceItem.create!(quantity: 4, unit_price: 75, item_id: item3.id, invoice_id: invoice1.id)

    invoice_item4 = InvoiceItem.create!(quantity: 4, unit_price: 75, item_id: item2.id, invoice_id: invoice2.id)
    invoice_item5 = InvoiceItem.create!(quantity: 4, unit_price: 75, item_id: item3.id, invoice_id: invoice2.id)
 
    invoice_ids = [invoice1.id, invoice2.id, invoice3.id, invoice4.id]
    Invoice.delete_empty_invoices(invoice_ids)

    expect(Invoice.count).to eq(2)
  end
end