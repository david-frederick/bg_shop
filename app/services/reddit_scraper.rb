class RedditScraper
  def scrape
    data = RedditParser.new.parse
    write_to_airtable(data)
  end

  def write_to_airtable(data)
    # Pass in api key to client
    @at_client = Airtable::Client.new('keyTycbrAXKjR7VPu')
    @at_flgs   = @at_client.table('appPJ6HUieDnNWxOi', 'FLGS')

    write_records(data)
  end

  def write_records(countries)
    countries.each do |country|
      country[:regions].each do |region|
        region[:cities].each do |city|
          city[:stores].each do |store|
            store[:pg_id] = Shop.create!.id
            write_flgs(country: country, region: region, city: city, **store)
          end
        end
      end
    end
  end

  def write_flgs(name: '', url: '', data: '', followup: '', phone: '', country: '', region: '', city: '', **blah)
    record = Airtable::Record.new(
      'Name'     => name,
      'URL'      => url,
      'Data'     => data,
      'Followup' => followup.try('join', '\n'),
      'Phone'    => phone,
      'Country'  => country[:name],
      'Region'   => region[:name] == :default ? '' : region[:name],
      'City'     => city[:name] == :default ? '' : city[:name],
      'PGID'     => blah[:pg_id]
    )

    ap record

    ap @at_flgs.create(record)
  end
end
