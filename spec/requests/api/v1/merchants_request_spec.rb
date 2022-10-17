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
end