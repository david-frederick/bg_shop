class GamesController < ApplicationController
  def index
    @games = Game.complete.all
  end
end
