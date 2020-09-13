# Guide to using Knock for React/Rails

The first time I used Knock I didn't understand it at all and the official docs don't exactly hand hold you through the process.

I've written the below as a very simple quick start guide on how to use Knock with a React/Rails website.

This is extremely minimalist and not a copy paste solution! Use this only to get an understanding of the gem before adding your own security layers.

The other half to this tutorial can be found [here](https://github.com/Chris-Stevenson-Git/Knock-Example-React)

## Setup

### Create the project
Create your rails app with a Postgres database

```bash
rails new your_project -d postgresql
```
Navigate into your project folder and open in your editor. Make sure the below gems are installed on your system and active in the gemfile.
```ruby
gem 'bcrypt', '~> 3.1.7'
gem 'rack-cors'
gem 'knock'
gem 'jwt'
gem 'pry-rails'
```

Then we need to run a few more commands in the terminal to finish the main structure of our back end.

```bash
#bundle the above gems
bundle install

#Setup commands for Knock structure
rails generate knock:install
rails generate knock:token_controller user

#Setup controller and model
rails generate model User name:text email:text password_digest:text
rails generate controller users

#Setup database
rails db:create
rails db:migrate
```

### Time to edit!
Now it's time to jump into the text editor!

We need to configure knock to work with our application. You can just uncomment these lines if you want in your file but I've put a clean list below of what needs to exist in your file.

Go to:
```bash
/config/initializers/knock.rb
```
Make sure the file has these lines
```rb
  config.token_lifetime = 1.day
  config.token_signature_algorithm = 'HS256'
  config.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }
  config.not_found_exception_class_name = 'ActiveRecord::RecordNotFound'
```
It should look like this..
![knock.rb](https://i.imgur.com/4LNowkb.png)

Next we need to set up our User model to accept secure passwords.

Go to your user model and ensure it has this code.
```rb
class User < ApplicationRecord
  has_secure_password
end
```
We're now ready to set up the controllers.

### Application Controller

Go to your Application Controller and enter the below code.
This adds the Knock authenticator into your controllers and also skips the authenticity error you'd otherwise be getting.

```rb
class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  include Knock::Authenticable

end
```

### Users Controller
As this is a VERY basic example, we're only going to have a single user method to return the current logged in user.

We also have a before_action to authenticate the user which will ensure only logged in users are able to access these methods

NOTE!! - Knock uses current_user NOT @current_user as we have used previously in a sessions controller. Ensure your code is typed as below.

```rb
class UsersController < ApplicationController

  before_action :authenticate_user

  def current
    render json: current_user
  end

end
```

### User Token Controller
This is a controller created by knock to handle our login sessions. We only need to add one line in here..
```rb
class UserTokenController < Knock::AuthTokenController
  skip_before_action :verify_authenticity_token
end
```

You might be wondering why we need to skip the authenticity verification again? We just put this in the application controller so why wouldn't our user token controller just inherit the behaviour?

Look closely at the class for UserTokenController. It actually inherits from Knock::AuthTokenController and not the Application Controller so we do need to manually add this behaviour here.


### Routes
Your routes file only needs two routes. We have a post route to the user_token to create our login session.

We also have a route to our users controller to return the current user as a json object.

```rb
Rails.application.routes.draw do

  #Get the login token from Knock
  post 'user_token' => 'user_token#create'

  #User routes
  get '/users/current' => 'users#current'

end
```

### CORS
We don't want to get the CORS error on our front end so we need to set up our cors.rb file.

Create a new file at the below path
```
config/initializers/cors.rb
```
It should look like this in your editor..

![cors.rb](https://i.imgur.com/xN1T7oD.png)

Now insert the middleware into cors.rb
```rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete]
  end
end
```

### Seed the database
We're almost done on the back end, last thing is to just seed the database.

Below is some seed data you can use or create your own
```rb
print "Creating Users..."
User.destroy_all

u1 = User.create!(
  name:'Jeff Winger',
  email: 'jwinger@ga.com',
  password: 'chicken'
)

u1 = User.create!(
  name:'Annie Edison',
  email: 'aedison@ga.com',
  password: 'chicken'
)

u1 = User.create!(
  name:'Troy Barnes',
  email: 'tbarnes@ga.com',
  password: 'chicken'
)

puts "Created #{ User.count } users:"
```

Then of course a
```bash
rails db:seed
```
and we're ready to get started on the front end.

### Start your server
```
rails s
```

The tutorial continues on the React repo [here](https://github.com/Chris-Stevenson-Git/Knock-Example-React).
