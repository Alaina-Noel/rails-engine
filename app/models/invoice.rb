class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items

  def self.delete_empty_invoices(array_of_invoice_ids)
    # Invoice.left_joins(:invoice_items).select("count(invoice_items) as inv_item_count").where(id: array_of_invoice_ids).group(:id).where(inv_item_count: 0)
    Invoice.find(array_of_invoice_ids).each do |invoice|
      if invoice.invoice_items.empty?
        invoice.delete
      end
    end
  end
end
