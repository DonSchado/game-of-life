Rails.application.routes.draw do
  post '/game_of_life', to: 'game_of_life#create', as: :game_of_life
  get '/:state', to: 'game_of_life#index'

  root to: 'game_of_life#index'
end
