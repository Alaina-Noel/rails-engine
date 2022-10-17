require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    merchant = create(:merchant)
    items = create_list(:item, 10)
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
      expect(item_data[:attributes][:unit_price]).to be_a(Float)
    end
  end

    it "can get one item by its id" do 
      id = create(:item).id
  
      get "/api/v1/items/#{id}"
  
      item_data = JSON.parse(response.body, symbolize_names: true)
  
      expect(response).to be_successful
      expect(item_data[:data]).to have_key(:id)
      expect(item_data[:data][:id]).to eq(id.to_s)
    
      expect(item_data[:data]).to have_key(:type)
      expect(item_data[:data][:type]).to eq("item")
    
      expect(item_data[:data]).to have_key(:attributes)
      expect(item_data[:data][:attributes][:name]).to be_a(String)
    end

  #   describe 'sad path' do
  #     it "can get one item by its id" do   
  #       get "/api/v1/items/9999111"
    
  #       item_data = JSON.parse(response.body, symbolize_names: true)
  #       expect(response.status).to eq(404)
  #     end
  # end
end