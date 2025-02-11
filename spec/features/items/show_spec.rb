require 'rails_helper'

describe 'Item Show Page' do
  before(:each) do
    @dog_shop = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)

    @pull_toy = @dog_shop.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
    @dog_bone = @dog_shop.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:false, inventory: 2)

    @review_1 = @pull_toy.reviews.create(title: "This toy rules", content: "I bought this for my dog and it rules", rating: 5)
    @review_2 = @pull_toy.reviews.create(title: "This toy sucks", content: "My dog hates this toy", rating: 1)
  end

  it "displays an item's name, description, price, image, status, inventory, and merchant" do
    visit "/items/#{@pull_toy.id}"

    expect(page).to have_link(@pull_toy.merchant.name)
    expect(page).to have_content(@pull_toy.name)
    expect(page).to have_content(@pull_toy.description)
    expect(page).to have_content("Price: $#{@pull_toy.price}")
    expect(page).to have_content("Active")
    expect(page).to have_content("Inventory: #{@pull_toy.inventory}")
    expect(page).to have_content("Sold by: #{@dog_shop.name}")
    expect(page).to have_css("img[src*='#{@pull_toy.image}']")
  end

  it 'displays reviews for that item' do
    visit "/items/#{@pull_toy.id}"

    within "#review-#{@review_1.id}" do
      expect(page).to have_content(@review_1.title)
      expect(page).to have_content(@review_1.content)
      expect(page).to have_content(@review_1.rating)
    end

    within "#review-#{@review_2.id}" do
      expect(page).to have_content(@review_2.title)
      expect(page).to have_content(@review_2.content)
      expect(page).to have_content(@review_2.rating)
    end
  end

  it "sorts reviews best-worst for an item" do
    visit "/items/#{@pull_toy.id}/?sort=highest-lowest"

    expect(@pull_toy.reviews.first).to eq(@review_1)
  end

  it "sorts reviews worst-best for an item" do
    visit "/items/#{@pull_toy.id}/?sort=lowest-highest"

    expect(@pull_toy.reviews.first).to eq(@review_1)
  end

  it 'has a link to the merchant that sells the item' do
    visit "/items/#{@pull_toy.id}"

    expect(page).to have_link(@dog_shop.name)

    click_link "#{@dog_shop.name}"

    expect(current_path).to eq("/merchants/#{@dog_shop.id}")
  end

  it 'has a link to update the item' do
    visit "/items/#{@pull_toy.id}"

    expect(page).to have_link("Edit Item")

    click_link "Edit Item"

    expect(current_path).to eq("/items/#{@pull_toy.id}/edit")
  end

  describe "has a link to add the item to the cart" do
    it "if the item can be added" do
      visit "/items/#{@dog_bone.id}"

      expect(page).to have_button("Add Item To yo Cart")

      click_button "Add Item To yo Cart"

      expect(page).to have_content("Inventory: 1")

      within '.topnav' do
        expect(page).to have_link("Items in Cart: 1")
      end
    end

    it "if the item cannot be added" do
      visit "/items/#{@dog_bone.id}"

      click_button "Add Item To yo Cart"

      visit "/items/#{@dog_bone.id}"

      click_button "Add Item To yo Cart"

      visit "/items/#{@dog_bone.id}"

      click_button "Add Item To yo Cart"

      expect(page).to have_content("Inventory: 0")

      within '.topnav' do
        expect(page).to have_link("Items in Cart: 2")
      end

      expect(page).to have_content("There are not enough #{@dog_bone.name}s to add to yo cart, sry.")
    end
  end

  describe 'has a link to delete the item' do
    it 'if the item has reviews' do
      visit "/items/#{@pull_toy.id}"

      expect(page).to have_link("Delete Item")

      click_link "Delete Item"

      expect(current_path).to eq("/items")
      expect(page).to_not have_css("#item-#{@pull_toy.id}")
    end

    it 'if the item has no reviews' do
      dog_bone = @dog_shop.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:false, inventory: 21)

      visit "/items/#{dog_bone.id}"

      expect(page).to have_link("Delete Item")

      click_link "Delete Item"

      expect(current_path).to eq("/items")
      expect(page).to_not have_css("#item-#{dog_bone.id}")
    end

    it 'if the item has been ordered' do
      order = Order.create(name: "Evette", address: "123 street", city: "Denver", state: "CO", zip: 12345)
      order.item_orders.create(item_id: @pull_toy.id, order_id: order.id, quantity: 5, total_cost: (@pull_toy.price * 5))

      visit "/items/#{@pull_toy.id}"

      expect(page).to have_link("Delete Item")

      click_link "Delete Item"

      expect(current_path).to eq("/items/#{@pull_toy.id}")
      expect(page).to have_content("We won't delete items with active orders pending")
    end

    it "and shows a message if the deleted item is queried" do
      visit "/items/#{@pull_toy.id}"

      expect(page).to have_link("Delete Item")

      click_link "Delete Item"

      visit "/items/#{@pull_toy.id}"

      expect(current_path).to eq("/items")

      expect(page).to have_content("This item doesn't exist")
    end

    it "doesn't delete if added to cart" do
      visit "/items/#{@pull_toy.id}"
      click_button "Add Item To yo Cart"

      visit "/items/#{@pull_toy.id}"
      click_on "Delete Item"

      expect(page).to have_content("We won't delete items that are in your cart.")
    end

    it "if other items are in the cart" do
      visit "/items/#{@dog_bone.id}"
      click_button "Add Item To yo Cart"

      visit "/items/#{@pull_toy.id}"
      click_on "Delete Item"

      expect(current_path).to eq("/items")
      expect(page).to_not have_content(@pull_toy.name)
    end 

    it "if other items are in the cart" do
      order = Order.create(name: "Evette", address: "123 street", city: "Denver", state: "CO", zip: 12345)
      io_1 = order.item_orders.create(item_id: @pull_toy.id, order_id: order.id, quantity: 5, total_cost: (@pull_toy.price * 5))
      visit "/items/#{@dog_bone.id}"
      click_button "Add Item To yo Cart"

      visit "/items/#{@pull_toy.id}"
      click_on "Delete Item"

      expect(page).to have_content("We won't delete items with active orders")
    end 
  end

  it 'has a button to add a review' do
    visit "/items/#{@pull_toy.id}"

    expect(page).to have_button("Add Review")

    click_button "Add Review"

    expect(current_path).to eq("/items/#{@pull_toy.id}/reviews/new-review")
  end

  it 'has a link to edit each review' do
    visit "/items/#{@pull_toy.id}"

    within "#review-#{@review_1.id}" do
      expect(page).to have_link("Edit this Review")

      click_link "Edit this Review"
    end

    expect(current_path).to eq("/items/#{@pull_toy.id}/reviews/#{@review_1.id}/edit-review")

    visit "/items/#{@pull_toy.id}"

    within "#review-#{@review_2.id}" do
      expect(page).to have_link("Edit this Review")

      click_link "Edit this Review"
    end

    expect(current_path).to eq("/items/#{@pull_toy.id}/reviews/#{@review_2.id}/edit-review")
  end

  it 'has a link to delete each review' do
    visit "/items/#{@pull_toy.id}"

    within "#review-#{@review_1.id}" do
      expect(page).to have_link("Delete this Review")

      click_link "Delete this Review"
    end

    expect(current_path).to eq("/items/#{@pull_toy.id}")
    expect(page).to_not have_content(@review_1.title)
    expect(page).to_not have_content(@review_1.content)

    visit "/items/#{@pull_toy.id}"

    within "#review-#{@review_2.id}" do
      expect(page).to have_link("Delete this Review")

      click_link "Delete this Review"
    end

    expect(current_path).to eq("/items/#{@pull_toy.id}")
    expect(page).to_not have_content(@review_2.title)
    expect(page).to_not have_content(@review_2.content)
  end

  it "displays review statistics" do
    review_3 = @pull_toy.reviews.create(title: "It's ok", content: "My dog got bored with this", rating: 3)
    review_4 = @pull_toy.reviews.create(title: "Nice; A Little Expensive", content: "Good quality.", rating: 4)
    review_5 = @pull_toy.reviews.create(title: "Buy 7!", content: "Fido loves these!", rating: 5)
    review_6 = @pull_toy.reviews.create(title: "Mehhh", content: "There are better options", rating: 2)

    visit "/items/#{@pull_toy.id}"

    within "#best-reviews" do
      expect(page).to have_content(@review_1.title)
      expect(page).to have_content(@review_1.rating)
      expect(page).to have_content(review_4.title)
      expect(page).to have_content(review_4.rating)
      expect(page).to have_content(review_5.title)
      expect(page).to have_content(review_5.rating)
    end

    within "#worst-reviews" do
      expect(page).to have_content(@review_2.title)
      expect(page).to have_content(@review_2.rating)
      expect(page).to have_content(review_3.title)
      expect(page).to have_content(review_3.rating)
      expect(page).to have_content(review_6.title)
      expect(page).to have_content(review_6.rating)
    end

    expect(page).to have_content(3.3)
  end

  it "has a button to add the item to the cart" do
    visit "/items/#{@pull_toy.id}"

    expect(page).to have_button("Add Item To yo Cart")

    click_button "Add Item To yo Cart"

    expect(current_path).to eq('/items')
    expect(page).to have_content("Items in Cart: 1")
  end
end
