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
    id = result["user_id"]

    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = id
        redirect('/items/index')
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
    redirect('/login')

    else
        "Oops something went wrong, please try again!"
end
end

get('/items/index') do
    db = SQLite3::Database.new("databas/databas.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM item")
    slim(:"items/index", locals: {items: result})
end

get('/items/new') do
    slim(:"items/new")
end

post('/items/new') do
    name = params[:name]
    description = params[:description]
    price = params[:price]
    location = params[:location]
    image = params[:image]
    user_id = session[:user_id]

    db = SQLite3::Database.new("databas/databas.db")
    db.results_as_hash = true
    
    db.execute("INSERT INTO item (name, user_id, description, price, location, image) VALUES(?,?,?,?,?,?)",name, user_id, description, price, location, image)
    redirect('/items/index')
end

post("/logout") do
    session.destroy
    redirect('/')
end

post('/items/delete/:item') do
    id = params[:item].to_i
    user_id = session[:user_id].to_i
    db = SQLite3::Database.new("databas/databas.db")
    db.execute("DELETE FROM item WHERE item_id = ?",id)
    redirect('/items/index')
end