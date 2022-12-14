class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices

  def self.search_for_all(string)
    where('name ILIKE ?', "%#{string}%").order('name')
  end

  def self.find_matching_merchant(string)
    where('name ILIKE ?', "%#{string}%").order('name').first
  end
end