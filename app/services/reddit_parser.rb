class RedditParser
  FLGS_PAGE = Nokogiri::HTML(open("/users/davidfrederick/Desktop/reddit_flgs.htm"))

  def parse
    page = FLGS_PAGE.css("div[class='md wiki']").to_s
    @lines = page.split("\n")
    @countries = []
    populate_countries
    @countries
  end

  def populate_countries
    identify_countries
    identify_country_endings

    @countries.each do |country|
      populate_regions(country)
    end
  end

  def identify_countries
    @lines.each_with_index do |line, index|
      case line
      when /<h2 id=\".*\">(.*)<\/h2>/ # country
        @countries << { name: "#{$1}", start: index }
      else
        next
      end
    end
  end

  def identify_country_endings
    @countries.each_with_index do |country, index|
      if index == @countries.length - 1
        country[:end] = @lines.length
      else
        country[:end] = @countries[index+1][:start] - 1
      end
    end
  end

  def populate_regions(country)
      identify_regions(country)
      identify_region_endings(country)
      default_regionless_countries(country)

      country[:regions].each do |region|
        populate_cities(region)
      end
  end

  def identify_regions(country)
    start = country[:start]
    finish = country[:end]
    country[:regions] = []

    @lines[start..finish].each_with_index do |line, index|
      case line
      when /<h3 id=\".*\">(.*)<\/h3>/ # region
        country[:regions] << { name: "#{$1}", start: index + start }
      else
        next
      end
    end
  end

  def identify_region_endings(country)
    country[:regions].each_with_index do |region, index|
      if index == country[:regions].length - 1
        region[:end] = country[:end]
      else
        region[:end] = country[:regions][index+1][:start] - 1
      end
    end
  end

  def default_regionless_countries(country)
    return if country[:regions].length > 0
    country[:regions] << { name: :default, start: country[:start] + 1, end: country[:end] }
  end

  def populate_cities(region)
    identify_cities(region)
    identify_city_endings(region)
    default_cityless_regions(region)

    region[:cities].each do |city|
      populate_stores(city)
    end
  end

  def identify_cities(region)
    start = region[:start]
    finish = region[:end]
    region[:cities] = []

    @lines[start..finish].each_with_index do |line, index|
      case line
      when /<p><strong>(.*)<\/strong><\/p>/ # city
        region[:cities] << { name: "#{$1}", start: index + start }
      else
        next
      end
    end
  end

  def identify_city_endings(region)
    region[:cities].each_with_index do |city, index|
      if index == region[:cities].length - 1
        city[:end] = region[:end]
      else
        city[:end] = region[:cities][index+1][:start] - 1
      end
    end
  end

  def default_cityless_regions(region)
    return if region[:cities].length > 0
    region[:cities] << { name: :default, start: region[:start], end: region[:end] }
  end

  def populate_stores(city)
    identify_stores(city)
    identify_store_endings(city)

    city[:stores].each do |store|
      identify_store_followup(store)
      parse_store_data(store)
    end
  end

  def identify_stores(city)
    start = city[:start]
    finish = city[:end]
    city[:stores] = []

    @lines[start..finish].each_with_index do |line, index|
      case line
      when /<a href=\"(.*)\" rel=\"nofollow\">(.*)<\/a>(.*)/ # store
        city[:stores] << { name: "#{$2}", url: "#{$1}", data: "#{$3}", start: index + start }
      else
        next
      end
    end
  end

  def identify_store_endings(city)
    city[:stores].each_with_index do |store, index|
      if index == city[:stores].length - 1
        store[:end] = city[:end]
      else
        store[:end] = city[:stores][index+1][:start] - 1
      end
    end
  end

  def identify_store_followup(store)
    start = store[:start]
    finish = store[:end]
    return if finish - start == 1
    store[:followup] = @lines[start+1..finish]
  end

  def parse_store_data(store)
    data = store[:data]
    store[:phone] = find_phone(data)
  end

  def find_phone(data)
    data.gsub(/\(|\)|-|\+|\s/, '')[/\d{9,12}/]
  end
end
