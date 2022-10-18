class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items

  def self.delete_empty_invoices
    Invoice.all.each do |invoice|
      if invoice.invoice_items.empty?
        invoice.delete
      end
    end
  end
end