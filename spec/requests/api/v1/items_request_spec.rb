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

  it "can create a new item" do
    merchant = create(:merchant)

    new_item_params = ({
                          name: 'Green Goblin Eyes',
                          description: 'the googliest eyes',
                          unit_price: 333.99,
                          merchant_id: merchant.id
                        })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: new_item_params)
    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq(new_item_params[:name])
    expect(created_item.description).to eq(new_item_params[:description])
    expect(created_item.unit_price).to eq(new_item_params[:unit_price])
    # expect(created_item.genre).to eq(new_item_params[:genre])
  end

  xit "can update an existing item" do
    id = create(:item).id
    create(:item)
    create(:item)
    create(:item)

    previous_name = Item.last.name
    item_params = { name: "Pink Earrings" }
    headers = {"CONTENT_TYPE" => "application/json"}
    
    # We include this header to make sure that these params are passed as JSON rather than as plain text
    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({book: item_params})
    item = Item.find_by(id: id)
  
    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("Pink Earrings" )
  end

  xit "can delete an item" do
    item = create(:item)
  
    expect(Item.count).to eq(1)
  
    delete "/api/v1/items/#{item.id}"
  
    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

end