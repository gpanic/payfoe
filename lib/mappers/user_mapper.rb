require_relative 'data_mapper'

class UserMapper < DataMapper
  COLUMNS = "id, username, email, name, balance"

  def insert_stm
    "INSERT INTO users VALUES (NULL, ?, ?, ?, ?)"
  end

  def find_stm
    "SELECT #{COLUMNS} FROM users WHERE id = ?"
  end

  def find_all_stm
    "SELECT #{COLUMNS} FROM users"
  end

  def update_stm
    "UPDATE users SET username = ?, email = ?, name = ?, balance = ? WHERE id = ?"
  end

  def delete_stm
    "DELETE FROM users WHERE id = ?"
  end

  def map
    IdentityMap.user_map
  end

  def do_load(id, rs)
    user = User.new(id, rs[1], rs[2], rs[3])
  end

  def do_insert(user, stm)
    stm.bind_param 1, user.username
    stm.bind_param 2, user.email
    stm.bind_param 3, user.name
    stm.bind_param 4, user.balance
  end

  def do_update(user, stm)
    stm.bind_param 1, user.username
    stm.bind_param 2, user.email
    stm.bind_param 3, user.name
    stm.bind_param 4, user.balance
    stm.bind_param 5, user.id
  end

end
