class GameOfLifeController < ApplicationController
  def index
    @game_of_life = GameOfLife.new(state: params[:state])
  end

  def create
    @game_of_life = GameOfLife.new(game_params).generation
  end

  private

  def game_params
    params.require(:game).permit(:state)
  end
end
