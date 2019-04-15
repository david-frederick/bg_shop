class Shop < ApplicationRecord
  scope :with_cart, -> { where(has_cart: true) }
  scope :with_site, -> { where(has_site: true) }

  after_create :verify

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
    if url_valid && !facebook? && ShopScraper.new(self).site_valid?
      self.has_site = true
    else
      self.has_site = false
    end
    self.save!
  end

  def verify_cart
    if has_site && ShopScraper.new(self).has_cart?
      self.has_cart = true
    else
      self.has_cart = false
    end
    self.save!
  end

  def facebook?
    url =~ /^https:\/\/www.facebook.com\/(.*)$/
  end
end
