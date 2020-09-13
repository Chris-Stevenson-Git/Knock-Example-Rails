Rails.application.routes.draw do

  #Get the login token from Knock
  post 'user_token' => 'user_token#create'

  #user routes
  get '/users/current' => 'users#current'

end
