require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pry'
require 'pg'
# mail sender
require 'pony'


enable :sessions

# postgres への接続文
client = PG::connect(
    :host => "localhost",
    :user => ENV.fetch("USER", "daichikato"), :password => '',
    :dbname => "myapp"
  )

# mypage
get "/mypage/:name" do
    return erb :mypage
end

get "/mypage" do
    @name = params[:user]
    return erb :mypage
end

#   signup
get '/signup' do
    return erb :signup
end

post '/signup' do
    name = params[:name]
    email = params[:email]
    password = params[:password]

    client.exec_params(
        "INSERT INTO users (name, email, password) VALUES ($1, $2, $3)", 
        [name, email, password]
    )
    user = client.exec_params(
        "SELECT * from users WHERE email = $1 AND password = $2", 
        [email, password]).to_a.first
        #.to_a.firstのイメージ {"name" => ‘kabi1’ , "email" => ‘kabi1@email.com’ , "password" => ‘kabipass’ }
    session[:user] = user
    # mail sender
    @isSuccessSendingEmail = 
    Pony.mail(:to => "#{name}<#{email}>",
              :body => "Please confirm email !",
              :subject => "Hello #{name} !",
              :from => "miyoshimasayasu@gmail.com",
              :via => :smtp, 
              :via_options => {
                :enable_starttls_auto => true,
                :address => "smtp.gmail.com",
                :port => "587",
                :user_name => "miyoshimasayasu@gmail.com",
                :password => "ueifaxlbkmvjbosa",
                :authentication => :plain,
                :domain => "gmail.com"
              }
    )
 return redirect '/mypage'
end

get "/mypage" do
    @name = session[:user] # 書き換える
    return erb :mypage
  end

#   signin

get "/signin" do
    return erb :signin
end

post '/signin' do
    email = params[:email]
    password = params[:password]
    

    user = client.exec_params(
    "SELECT * FROM users WHERE email = $1 AND password = $2 LIMIT 1",
    [email, password]
    ).to_a.first

    if user.nil?
      return erb :signin
    else
      session[:user] = user
      return redirect '/mypage'
    end
  end

#   signout

delete '/signout' do
  session[:user] = nil
  return redirect '/signin'
  end

#  form

 post "/form_reciver" do
     @value1 = params[:value1]
     @value2 = params[:value2]
     @value3 = params[:value3]
     
     if !params[:img].nil? # データがあれば処理を続行する
         tempfile = params[:img][:tempfile] # ファイルがアップロードされた場所
         save_to = "./public/images/#{params[:img][:filename]}" 
         # ファイルを保存したい場所
         FileUtils.mv(tempfile, save_to)
         @img_name = params[:img][:filename]
     end
    return erb :form_receiver
 end

 get "/form" do
    return erb :form
end

get "/index" do
  return erb :index
end

get "/index.erb" do
  return erb :index
end

delete '/index' do
  @_method = cookies[:user]
    @DELETE = params[:DELETE]
  return erb :index
end

# post '/index' do
#   email = params[:email]
#   password = params[:password]

#   user = client.exec_params(
#   "SELECT * FROM users WHERE email = $1 AND password = $2 LIMIT 1",
#   [email, password]
#   ).to_a.first

#   if user.nil?
#     return erb :signin
#   else
#     session[:user] = user
#     return redirect '/mypage'
#   end
# end




# logout

get "/logout" do
    return erb :logout
  end

post "/logput" do
    cookies[:user] = params[:name]
    redirect '/signin'
  end

get "/mypage" do
    @_method = cookies[:user]
    @DELETE = params[:DELETE]
    return erb :mypage
  end