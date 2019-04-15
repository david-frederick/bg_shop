class Shop < ApplicationRecord
  scope :with_cart, -> { where(has_cart: true) }
  scope :with_site, -> { where(has_site: true) }

  has_many :shop_games
  has_many :games, through: :shop_games

  after_initialize :init_scraper
  after_create :verify

  def init_scraper
    @scraper = ShopScraper.new(self)
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
    if url_valid && !facebook? && @scraper.site_valid?
      self.has_site = true
    else
      self.has_site = false
    end
    self.save!
  end

  def verify_cart
    if has_site && @scraper.has_cart?
      self.has_cart = true
    else
      self.has_cart = false
    end
    self.save!
  end

  def facebook?
    url =~ /^https:\/\/www.facebook.com\/(.*)$/
  end

  def update_search_url
    if @scraper.scrape_for_search.present?
      self.search_string = @scraper.scrape_for_search.gsub(/burdell/, '{{ content }}')
      self.save!
    end
  end

  # def validate_search(search_text)
  #   return false unless search_string.present?
  #   search_url = search_string.gsub(/{{ content }}/, search_text)
  #   @scraper.
  # end
end
