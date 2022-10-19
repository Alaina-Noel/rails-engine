require 'rails_helper'

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)
    expect(merchants[:data].count).to be(3)

    merchants[:data].each do |merchant_data|
      expect(merchant_data).to have_key(:id)
      expect(merchant_data[:id]).to be_a(String)

      expect(merchant_data).to have_key(:type)
      expect(merchant_data[:type]).to be_a(String)
      expect(merchant_data[:type]).to eq("merchant")

      expect(merchant_data).to have_key(:attributes)
      expect(merchant_data[:attributes]).to be_a(Hash)
      expect(merchant_data[:attributes][:name]).to be_a(String)
    end
  end

  it "can get one merchant by its id" do 
    id = create(:merchant).id
    get "/api/v1/merchants/#{id}"
    merchant_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchant_data[:data]).to have_key(:id)
    expect(merchant_data[:data][:id]).to eq(id.to_s)
  
    expect(merchant_data[:data]).to have_key(:type)
    expect(merchant_data[:data][:type]).to eq("merchant")
  
    expect(merchant_data[:data]).to have_key(:attributes)
    expect(merchant_data[:data][:attributes][:name]).to be_a(String)
  end

  describe 'sad path' do
    it "can return 404 if the merchant is not found" do 
      get "/api/v1/merchants/999999999"
      error_response = JSON.parse(response.body, symbolize_names: true)
      expect(response.status).to eq(404)
      expect(error_response).to have_key(:error)
      expect(error_response[:error]).to eq("No merchant found")
    end
  end

  it "can display all items associated with a specified merchant " do
    merchant = create(:merchant)
    item1 = Item.create!(name: "An Item", description: "I belong to a merchant", unit_price: 222, merchant_id: merchant.id)
    item2 = Item.create!(name: "Another Item", description: "I also belong to a merchant", unit_price: 222,merchant_id: merchant.id) 
    item3 = Item.create!(name: "And Another Item", description: "I belong to a merchant, too!",unit_price: 222, merchant_id: merchant.id)

    get "/api/v1/merchants/#{merchant.id}/items"

    expect(response).to be_successful

    items_array = JSON.parse(response.body, symbolize_names: true)
    expect(items_array[:data].count).to be(3)

    items_array[:data].each do |item_data|
      expect(item_data).to have_key(:id)
      expect(item_data[:id]).to be_a(String)

      expect(item_data).to have_key(:type)
      expect(item_data[:type]).to be_a(String)
      expect(item_data[:type]).to eq("item")

      expect(item_data).to have_key(:attributes)
      expect(item_data[:attributes]).to be_a(Hash)
      expect(item_data[:attributes][:name]).to be_a(String)
      expect(item_data[:attributes][:description]).to be_a(String)
    end
  end

  it "can display a 404 if a merchant has no items " do
    merchant = create(:merchant)
    
    get "/api/v1/merchants/#{merchant.id}/items"
    expect(response.status).to eq(404)
  end

  it "return a 200 and empty body if no match found for a search term" do
    merchant1 = Merchant.create!(name: "Turing")
    merchant2 = Merchant.create!(name: "Ring World")
    merchant2 = Merchant.create!(name: "Rose Rings")


    get "/api/v1/merchants/find_all?name=xxx"
    merchant_data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(200) 
    expect(merchant_data[:data]).to eq([])
  end

  it "return all merchants which match a query param" do
    merchant1 = Merchant.create!(name: "Turing")
    merchant2 = Merchant.create!(name: "Ring World")
    merchant3 = Merchant.create!(name: "Rose Rings")
    merchant4 = Merchant.create!(name: "XXQQ")

    get "/api/v1/merchants/find_all?name=ring"
    merchant_data = JSON.parse(response.body, symbolize_names: true)

    expect(merchant_data[:data].count).to eq(3)

    merchant_data[:data].each do |merchant_info|
      expect(response).to be_successful
      expect(merchant_info).to have_key(:id)
      expect(merchant_info[:id]).to be_a(String)
      expect(merchant_info[:attributes][:name]).to be_a(String)
    end
  end

  it "return one merchant by name matching a query param" do
    merchant1 = Merchant.create!(name: "Turing")
    merchant2 = Merchant.create!(name: "Ring World")
    merchant3 = Merchant.create!(name: "Rose Rings")
    merchant4 = Merchant.create!(name: "XXQQ")

    get "/api/v1/merchants/find?name=ring"
    merchant_data = JSON.parse(response.body, symbolize_names: true)

    expect(merchant_data.count).to eq(1)
    expect(merchant_data).to have_key(:data)
    expect(merchant_data[:data][:id]).to eq(merchant2.id.to_s)
    expect(merchant_data[:data][:type]).to eq("merchant")
    expect(merchant_data[:data][:attributes][:name]).to be_a(String)
    expect(merchant_data[:data][:attributes][:name]).to eq(merchant2.name.to_s)
  end

  it "returns a 200 and empty body if a the search param doesn't match any merchants" do
    merchant1 = Merchant.create!(name: "Turing")
    merchant2 = Merchant.create!(name: "Hello World")
    merchant3 = Merchant.create!(name: "Cotton Candy")
    merchant4 = Merchant.create!(name: "XPPPP")

    get "/api/v1/merchants/find?name=LLLLL"
    merchant_data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(200)
    expect(merchant_data).to have_key(:data)
    expect(merchant_data[:data]).to eq({})
  end

  it "returns a 404 & error if the user doesn't type in a query param" do
    merchant1 = Merchant.create!(name: "Turing")
    merchant2 = Merchant.create!(name: "Hello World")
    merchant3 = Merchant.create!(name: "Cotton Candy")
    merchant4 = Merchant.create!(name: "XPPPP")

    get "/api/v1/merchants/find?name="
    merchant_data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(404)
    expect(merchant_data).to have_key(:error)
    expect(merchant_data).to_not have_key(:data)
    expect(merchant_data[:error]).to eq('You must enter a query param')
  end
end