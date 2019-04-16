class Shop < ApplicationRecord
  scope :with_cart,  -> { where(has_cart: true) }
  scope :with_site,  -> { where(has_site: true) }
  scope :searchable, -> { where.not(search_string: nil) }

  has_many :shop_games
  has_many :games, through: :shop_games

  after_initialize :init_scraper
  after_create :verify

  def init_scraper
    @scraper = ShopScraper.new
  end

  def verify
    verify_url
    verify_site
    verify_cart
  end

  def verify_url
    begin
      URI.parse(url)
      self.url_valid = true
    rescue URI::InvalidURIError => e
      self.url_valid = false
    end
    self.save!
  end

  def verify_site
    if url_valid && !facebook? && @scraper.site_valid?(url)
      self.has_site = true
    else
      self.has_site = false
    end
    self.save!
  end

  def verify_cart
    if has_site && @scraper.has_cart?(url)
      self.has_cart = true
    else
      self.has_cart = false
    end
    self.save!
  end

  def facebook?
    url =~ /^https:\/\/www.facebook.com\/(.*)$/
  end

  def update_search_url(index = nil, total = nil)
    if index && total
      puts "  [#{index}/#{total}][id: #{self.id}] updating search url "
    else
      puts "  [id: #{self.id}] updating search url "
    end

    response = @scraper.extract_search_url(url)
    if response.present?
      self.search_string = response.gsub(/burdell/, '{{ content }}')
      self.save!
    end
  end

  def self.update_search_urls
    puts '----- UPDATING SEARCH URLS -----'
    shops = Shop.with_cart
    shops.each_with_index do |shop,index|
      shop.update_search_url(index, shops.count)
    end
  end
end
