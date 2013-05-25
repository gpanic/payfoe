require_relative 'data_mapper'

class TransactionMapper < DataMapper
  COLUMNS = "id, user_from, user_to, type, amount"

  def insert_stm
    "INSERT INTO transactions VALUES (NULL, ?, ?, ?, ?)"
  end

  def find_stm
    "SELECT #{COLUMNS} FROM transactions WHERE id = ?"
  end

  def find_all_stm
    "SELECT #{COLUMNS} FROM transactions"
  end

  def update_stm
    "UPDATE transactions SET user_from = ?, user_to = ?, type = ?, amount = ? WHERE id = ?"
  end

  def delete_stm
    "DELETE FROM transactions WHERE id = ?"
  end

  def map
    IdentityMap.transactions_map
  end

  def do_load(id, rs)
    transaction = Transaction.new(id, rs[1], rs[2], rs[3], rs[4])
  end

  def do_insert(transaction, stm)
    stm.bind_param 1, transaction.user_from
    stm.bind_param 2, transaction.user_to
    stm.bind_param 3, transaction.type
    stm.bind_param 4, transaction.amount
  end

  def do_update(transaction, stm)
    stm.bind_param 1, transaction.user_from
    stm.bind_param 2, transaction.user_to
    stm.bind_param 3, transaction.type
    stm.bind_param 4, transaction.amount
    stm.bind_param 5, transaction.id
  end

end
