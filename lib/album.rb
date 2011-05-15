require 'fake_data'
require 'haml'

class Album < ActiveRecord::Base
  include FakeData::HamlTemplate
  include FakeData::Random

  validates :name, :presence => true
  validates :uri, :presence => true,
                   :uniqueness => { :case_sensitive => false }

  has_and_belongs_to_many :artists
  has_many :tracks

  scope :with_cover, where('cover NOT NULL') 

  def artist_name
    artists.size > 1 ? "Various Artists" : artists.first.name
  end

  def to_powa
    @description_template = load_haml_template('album')
    @short_description_template = load_haml_template('album_short')

    [powa_sku ,powa_name, powa_price, powa_quantity, powa_weight, powa_category, powa_brand, powa_full_description, powa_short_description,powa_minimum_quantity, powa_image_url]
  end

private
  def powa_sku
    "album-#{id}"
  end

  def powa_name
    name
  end

  def powa_price
    random_price(5..10)
  end

  def powa_quantity
    random_value(1..10)
  end
  
  def powa_weight
    '0'
  end
  
  def powa_category
    "Artists/#{artist_name}"
  end

  def powa_brand
    ''
  end

  def powa_full_description
    haml_description
  end

  def powa_short_description
    haml_short_description
  end

  def powa_minimum_quantity
    '1'
  end

  def powa_image_url
    cover_url
  end

  def haml_description
    @description_template.render(Object.new, :album => self, :tracks => tracks.order('track_number ASC').all)
  end

  def haml_short_description
    @short_description_template.render(Object.new, :album => self)
  end
end
