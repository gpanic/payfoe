class UserMapper

  def initialize(db_path = "db/payfoe.db")
    @db_path = db_path
  end
  
  def db_path=(db)
    @db_path = db
  end

  def insert(user)
    db = SQLite3::Database.open @db_path
    stm = db.prepare "INSERT INTO users VALUES (NULL, ?, ?, ?)"
    stm.bind_param 1, user.username
    stm.bind_param 2, user.email
    stm.bind_param 3, user.name
    stm.execute
    stm.close
    id = db.last_insert_row_id
    db.close
    return id
  end

end
