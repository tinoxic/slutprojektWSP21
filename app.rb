require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

enable :sessions

db = SQLite3::Database.new("databas/databas.db")
db.results_as_hash = true