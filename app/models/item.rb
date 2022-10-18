class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  validates_presence_of :name, :description, :unit_price, :merchant_id
  validates_numericality_of :unit_price, only_float: true

  def self.find_matching_item(string)
    where('name ILIKE ?', "%#{string}%").order('name').first
  end
end