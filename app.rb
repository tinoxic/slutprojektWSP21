require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require "byebug"

enable :sessions

db = SQLite3::Database.new("databas/databas.db")
db.results_as_hash = true

get('/') do
    slim(:index)
end

get('/login') do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new("databas/databas.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?", username).first
    password_digest = result["password_digest"]
    id = result["id"]

    if BCrypt::Password.new(password_digest) == password
        session[:id] = id
        redirect('/home')
      else
        "FEL LÖSENORD"
      end
    end

get('/users/new') do
    slim(:"users/new")
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    phone_number = params[:phone_number]
    email = params[:email]

    if (password == password_confirm) && password.length >= 8 && username.length >=5 && username.length <=12 && phone_number.length == 10 && password =~ /[a-z]/ && password =~ /[A-Z]/

    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('databas/databas.db')
    db.execute("INSERT INTO users (username,password_digest,email,phone_number) VALUES (?,?,?,?)",username,password_digest,email,phone_number)
    redirect('/')

    else
        p "Oops something went wrong, please try again!"
end
end

