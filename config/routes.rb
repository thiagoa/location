Location::Engine.routes.draw do
  post '/finder', to: 'finder#show', as: 'location_finder' 
end
