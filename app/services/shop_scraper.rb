class ShopScraper
  def load_page(url)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new uri
    execute_request(uri, req)
  end

  def site_valid?(url)
    response = load_page(url)
    return false if response.nil?
    valid_response?(response)
  end

  def valid_response?(response)
    case response.code
    when /2\d\d/
      true
    when /3\d\d/
      true
    else
      false
    end
  end

  def execute_request(uri, req, retries = 0)
    return Net::HTTP.start(uri.host, uri.port,
                     :use_ssl => uri.scheme == 'https') { |http| http.request req }
  rescue URI::InvalidURIError => e
    return nil
  rescue SocketError => e
    return nil
  rescue Errno::ECONNREFUSED => e
    return nil
  rescue EOFError => e
    return nil
  rescue Net::OpenTimeout => e
    if retries >= 3
      return nil
    else
      retries += 1
      execute_request(uri, req, retries)
    end
  rescue => e
    puts '---- UNHANDLED ERROR ----'
    puts "  url: #{uri.to_s}"
    raise e
  end

  def has_cart?(url)
    response = load_page(url)
    return false unless valid_response?(response)
    /(cart)/i =~ response.body
  end

  def with_driver
    @driver = Selenium::WebDriver.for :firefox
    yield @driver
    @driver.quit
  rescue StandardError => e
    @driver.quit if defined? @driver
    raise e
  end

  def extract_search_url(url)
    with_driver do |driver|
      driver.navigate.to url

      element = driver.find_element(xpath: '//input')
      element.send_keys 'burdell'
      element.submit

      wait = Selenium::WebDriver::Wait.new(:timeout => 10)
      wait.until { driver.page_source.include? "burdell" }

      return driver.current_url
    end
  rescue StandardError => e
    nil # return nil if the scrape fails
  end
end
