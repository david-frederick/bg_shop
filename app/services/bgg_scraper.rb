class BggScraper
  RANK_URL = 'https://boardgamegeek.com/browse/boardgame'

  def scrape_rankings
    url = URI.parse(RANK_URL)
    req = Net::HTTP::Get.new url
    res = Net::HTTP.start(url.host, url.port,
        :use_ssl => url.scheme == 'https') { |http| http.request req }
    Nokogiri::HTML(res.body)
  end
end
