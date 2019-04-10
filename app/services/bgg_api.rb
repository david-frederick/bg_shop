class BggApi
  def retrieve_game_metadata(game)
    data = Nokogiri::XML(get_metadata(game))

    game.attributes = {
      description: data.xpath('//description')[0].to_s.gsub(/^\<description\>/, '').gsub(/\<\/description\>$/, ''),
      thumbnail: data.xpath('//thumbnail')[0].to_s.gsub(/^\<thumbnail\>/, '').gsub(/\<\/thumbnail\>$/, ''),
      image: data.xpath('//image')[0].to_s.gsub(/^\<image\>/, '').gsub(/\<\/image\>$/, ''),
      year_published: data.xpath('//yearpublished')[0].to_s.gsub(/[^\d]/, ''),
      min_players: data.xpath('//minplayers')[0].to_s.gsub(/[^\d]/, ''),
      max_players: data.xpath('//maxplayers')[0].to_s.gsub(/[^\d]/, ''),
      playtime: data.xpath('//playingtime')[0].to_s.gsub(/[^\d]/, ''),
      bgg_data_collected: true
    }

    game.save!
  end

  def get_metadata(game)
    url = URI.parse("https://www.boardgamegeek.com/xmlapi2/thing?type=boardgame&id=#{game.bgg_id}")
    req = Net::HTTP::Get.new url
    res = Net::HTTP.start(url.host, url.port,
        :use_ssl => url.scheme == 'https') {|http| http.request req}
    res.body
  end

  def test
    url = URI.parse('https://www.boardgamegeek.com/xmlapi2/thing?type=boardgame&id=237182')
    req = Net::HTTP::Get.new url
    res = Net::HTTP.start(url.host, url.port,
        :use_ssl => url.scheme == 'https') { |http| http.request req }
    puts res.body
  end
end
