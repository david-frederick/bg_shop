class BggParser
  def parse(page)
    games = []

    100.times do |index|
      game = page.css("td[id='CEcell_objectname#{ index + 1 }']").first
      link = game.css('a').first
      path = link.attributes['href'].to_s

      games << { bgg_id: path.gsub(/[^\d]/, ''),
                 name: link.children.to_s }
    end

    games
  end
end
