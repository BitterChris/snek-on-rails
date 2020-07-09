Rails.application.routes.draw do
  root 'static#index'

  post '/start', to: 'game#start'
  post '/move', to: 'game#move'
  post '/end', to: 'game#end'
end
