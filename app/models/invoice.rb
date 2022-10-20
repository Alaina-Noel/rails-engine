class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items

  def self.delete_empty_invoices(array_of_invoice_ids)
    Invoice.left_joins(:invoice_items).select("invoices.*, count(invoice_items) as inv_item_count").having("count(invoice_items) = 0").where(id: array_of_invoice_ids).group(:id).destroy_all
    #create a variable and delete that variable count for 1 - delete that variable.

    # require 'pry' ; binding.pry
    # Invoice.find(array_of_invoice_ids).each do |invoice|
    #   if invoice.invoice_items.empty?
    #     invoice.delete
    #   end
    # end
  end
end
