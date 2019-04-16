class RedditScraper
  def scrape
    data = RedditParser.new.parse
    write_records(data)
  end

  def write_records(countries)
    countries.each do |country|
      country[:regions].each do |region|
        region[:cities].each do |city|
          city[:stores].each do |store|
            shop = Shop.create!(url: store[:url])

            store[:pg_id]    = shop.id
            store[:country]  = country
            store[:region]   = region
            store[:city]     = city
            store[:has_cart] = shop.has_cart
            store[:has_site] = shop.has_site
            store[:bad_url]  = !shop.url_valid

            AirtableSyncher.new.write_flgs(**store)
          end
        end
      end
    end
  end
end
