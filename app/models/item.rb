class Item < ApplicationRecord
  belongs_to :merchant
  has_many :reviews
  has_many :item_orders
  has_many :orders, through: :item_orders

  validates_presence_of :name,
                        :description,
                        :image
  validates_inclusion_of :active?, :in => [true, false]
  validates :price, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :inventory, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def avg_rating
    reviews.average(:rating)
  end

  def best_reviews
    reviews.order(rating: :desc).limit(3)
  end

  def worst_reviews
    reviews.order(:rating).limit(3)
  end

  def buy
    if self.inventory > 0
      self.inventory -= 1
    end
    if self.inventory <= 0
      self.update(active?: false)
    end
    self.save
  end

  def restock(qty = 1)
    self.inventory += qty
    self.update(active?: true) if self.inventory > 0
    self.save
  end

  def activate
    self.update(active?: true) if self.inventory > 0
    self.update(active?: false) if self.inventory == 0
    self.save
  end

  def has_been_ordered?
    ids = Item.joins(:item_orders).pluck(:item_id)
    ids.include?(self.id)
  end
end
