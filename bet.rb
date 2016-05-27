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

get "/" do
  redirect "/bet"
end

get "/bet" do
  session[:bank] ||= 100 
  erb :bet
end

post "/bet" do
  winning_number = random_number
  amount_bet = params[:bet].to_i
  guess = params[:guess].to_i

  if amount_bet < 1 || amount_bet > session[:bank]
    session[:message] = "Bets must be between $1 and #{session[:bank]}."
    status 422
    erb :bet
  else
    if winning_number == guess
      session[:bank] = session[:bank] + amount_bet
      session[:message] = "You have guessed correctly. You now have $#{session[:bank]}"
    else
      session[:bank] = session[:bank] - amount_bet
      if session[:bank] <= 0
        session[:message] = "You guessed #{guess}, but the number was #{winning_number}. Your broke"
        redirect "/broke"
      else
        session[:message] = "You guessed #{guess}, but the number was #{winning_number}. You now have $#{session[:bank]}"
      end
    end
    redirect "/bet"
  end
end

get "/broke" do
  erb :broke
end
