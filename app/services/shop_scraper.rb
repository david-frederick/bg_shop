require 'selenium-webdriver'

class ShopScraper
  def initialize(shop)
    @shop = shop
    @url = ''
    @failure = false
    @retries = 0

    run_parse(shop.url)
  end

  def issue_search
    with_driver do
      @driver.navigate.to @shop.url

      element = @driver.find_element(xpath: 'input')
      element.send_keys 'burdell'
      element.submit

      puts @driver.title

      byebug
    end
  end

  def with_driver
    @driver = Selenium::WebDriver.for :firefox
    yeild
    @driver.quit
  end

  def run_parse(url)
    @url = URI.parse(url)
    @req = Net::HTTP::Get.new @url
    @res = Net::HTTP.start(@url.host, @url.port,
           :use_ssl => @url.scheme == 'https') { |http| http.request @req }

  rescue URI::InvalidURIError => e
    @failure = true
  rescue SocketError => e
    @failure = true
  rescue Errno::ECONNREFUSED => e
    @failure = true
  rescue EOFError => e
    @failure = true
  rescue Net::OpenTimeout => e
    if @retries >= 3
      @failure = true
    else
      @retries += 1
      run_parse(url)
    end
  rescue => e
    puts '---- UNHANDLED ERROR ----'
    puts "  url: #{url}"
    raise e
  end

  def site_valid?
    return false if @failure

    case @res.code
    when '200'
      true
    else
      false
    end
  end

  def has_cart?
    return false unless site_valid?
    /(cart)/i =~ @res.body
  end
end
