class GamesController < ApplicationController
  def index
    @games = Game.complete.all.sort_by { |game| game.name }
  end

  def show
    @game  = Game.find(params[:id])
    @shop_games = @game.shop_games
    @shop_games = @shop_games.to_a.map { |shop_game| { url: shop_game.url, shop: shop_game.shop } }

    puts '--'
    ap @shop_games.first
  end
end
