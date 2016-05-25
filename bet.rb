require "pry"
require "redcarpet"
require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "yaml"
require "bcrypt"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end


def random_number
  num = Random.new
  num.rand(1..3)
end

new_user = true

def process_bet(users_guess)
  winning_number = random_number
  amount_bet = params[:bet].to_i

  if amount_bet < 1 || amount_bet > session[:bank]
    session[:message] = "Bets must be between $1 and #{session[:bank]}."
    status 422
    erb :bet
  else
    if winning_number == users_guess
      session[:bank] = session[:bank] + amount_bet
      session[:message] = "You have guessed correctly. You now have $#{session[:bank]}"
    else
      session[:bank] = session[:bank] - amount_bet
      if session[:bank] <= 0
        session[:message] = "You guessed #{users_guess}, but the number was #{winning_number}. Your broke"
        redirect "/broke"
      else
        session[:message] = "You guessed #{users_guess}, but the number was #{winning_number}. You now have $#{session[:bank]}"
      end
    end
    redirect "/bet"
  end
end

get "/" do
  session[:bank] = 100 if new_user
  new_user = false
  redirect "/bet"
end

get "/bet" do
  erb :bet
end

post "/bet/guess1" do
  users_guess = 1
  process_bet(users_guess)
end

post "/bet/guess2" do
  users_guess = 2
  process_bet(users_guess)
end

post "/bet/guess3" do
  users_guess = 3
  process_bet(users_guess)
end

get "/broke" do
  erb :broke
end
