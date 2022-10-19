class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items

  def self.delete_empty_invoices(array_of_invoice_ids)
    #Do this with activerecord
    Invoice.find(array_of_invoice_ids).each do |invoice|
      if invoice.invoice_items.empty?
        invoice.delete
      end
    end
  end
end

#build a join where both things are true and it's empty and then delete it