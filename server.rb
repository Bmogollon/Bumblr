require "sinatra/activerecord"
require 'sinatra'

enable :sessions

if ENV['RACK_ENV']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

else
  set :database, {adapter: "sqlite3", database: "database.sqlite3"}
end

class User < ActiveRecord::Base

end

class Spost < ActiveRecord::Base

end


get '/' do
    p session

    erb :home
end
#####################
# SING IN

get "/login" do

  erb :"/users/login"
end

post "/login" do
  user = User.find_by(email: params["email"])

  if user != nil
    if user.password == params["password"]
      session[:user_id] = user.id
      redirect "/users/#{user.id}"
    else
      redirect "/"
    end

  end
end


post "/logout" do

  session["user_id"] = nil
  redirect "/"
end

####
# # SIGN UP
get "/users/signup" do
  if session['user_id'] != nil
    p "User already logged in"
    redirect "/"
  else
    erb :'/users/signup'
  end

end

post "/users/signup" do
  @user =  User.new(name: params[:name], email: params[:email], birthday: params[:birthday], password: params[:password])
  @user.save
  session[:user_id] = @user.id
  redirect "/users/#{@user.id}"
end


get "/users/:id" do
  @user =  User.find(params["id"])
  erb :"/users/profile"
  end

get "/users/?" do
  @user =  User.all
    erb :"/users/profile"
    end

post "/users/:id" do
  @user =  User.find(params["id"])
  @user.destroy

    session["user_id"] = nil
    redirect "/"
end


# **************

get "/sposts/spost" do
  if session['user_id'] == nil
    p 'User was not logged in'
    redirect '/'
    end
    erb :"sposts/spost"
end

post "/sposts/spost" do #CREATE
  @spost = Spost.new(title: params[:title], content: params[:content], user_id: session[:user_id])
  @spost.save
  redirect "/sposts/#{@spost.id}"
end
### SEE ALL POST
get '/sposts/allp' do
  @sposts = Spost.all
  erb :'/sposts/allp',:layout => false do
  end
end

######


get "/sposts/:id" do
  @spost =  Spost.find(params["id"])
  erb :"/sposts/content"
end


#to DELETE an spost, be careful on what you're writing on here!
get "/sposts/?" do
  @sposts = Spost.all
  erb :"/sposts/content"
end

post "/sposts/:id" do
  @spost =  Spost.find(params["id"])
  @spost.destroy

  redirect "/sposts/allp"
end



get "/everyp" do
  @spost = Spost.last(20)

  erb :everyp
end
