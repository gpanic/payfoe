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
    users = []
    rs[1,2].each do |user_id|
      if user_id
        if not user_from = IdentityMap.users_map[user_id]
          users.push LazyObject.new(user_id)
        end
      else
        users.push nil
      end
    end
    transaction = Transaction.new id, users[0], users[1], rs[3], rs[4]
  end

  def do_insert(transaction, stm)
    user_from = nil
    user_from = transaction.user_from.id unless transaction.user_from == nil
    user_to = nil
    user_to = transaction.user_to.id unless transaction.user_to == nil

    stm.bind_param 1, user_from
    stm.bind_param 2, user_to
    stm.bind_param 3, transaction.type
    stm.bind_param 4, transaction.amount
  end

  def do_update(transaction, stm)
    do_insert transaction, stm
    stm.bind_param 5, transaction.id
  end

end
