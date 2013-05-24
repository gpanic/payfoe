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

  def find(id)
    db = SQLite3::Database.open @db_path
    rs = db.get_first_row "SELECT * FROM users WHERE id = ?", id
    db.close
    if rs
      user = User.new(rs[0], rs[1], rs[2], rs[3])
    else
      nil
    end
  end

  def update(user)
    db = SQLite3::Database.open @db_path
    stm = db.prepare "UPDATE users SET username = ?, email = ?, name = ? WHERE id = ?"
    stm.bind_param 1, user.username
    stm.bind_param 2, user.email
    stm.bind_param 3, user.name
    stm.bind_param 4, user.id
    stm.execute
    stm.close
    db.close
    return nil
  end

  def delete(id)
    db = SQLite3::Database.open @db_path
    db.execute "DELETE FROM users WHERE id = ?", id
    db.close
    return nil
  end

  def find_all
    db = SQLite3::Database.open @db_path
    rs = db.execute "SELECT * FROM users"
    all = []
    rs.each do |row|
      all.push(User.new(row[0], row[1], row[2], row[3]))
    end
    return all
  end

end
