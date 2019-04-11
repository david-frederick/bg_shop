class GamesController < ApplicationController
  def index
    @games = Game.complete.all
  end

  def show
    @game = Game.find(params[:id])
  end
end
