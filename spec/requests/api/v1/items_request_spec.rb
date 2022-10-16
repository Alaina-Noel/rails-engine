require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    create_list(:item, 10)

    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data].count).to be(10)

    items[:data].each do |item_data|
      expect(item_data).to have_key(:id)
      expect(item_data[:id]).to be_a(String)

      expect(item_data).to have_key(:type)
      expect(item_data[:type]).to be_a(String)
      expect(item_data[:type]).to eq("item")

      expect(item_data).to have_key(:attributes)
      expect(item_data[:attributes]).to be_a(Hash)
      expect(item_data[:attributes][:description]).to be_a(String)
      expect(item_data[:attributes][:unit_price]).to be_a(String)
    end
  end
end