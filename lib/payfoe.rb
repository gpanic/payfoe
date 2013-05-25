require_relative 'db_helper'
require_relative 'entities/user'
require_relative 'entities/transaction'
require_relative 'mappers/user_mapper'
require_relative 'identity_map'

class PayFoe

  def initialize
    @user_mapper = UserMapper.new
  end
  
  def register(user)
    if !user.instance_of? User
      raise ArgumentError, 'user is invalid'
    end
    @user_mapper.insert(user)
  end

  def users
    @user_mapper.find_all
  end

  def deposit(user, amount)
    if !amount.kind_of? Numeric or amount <= 0
      raise ArgumentError, 'amount is invalid'
    end
    user.balance += amount
    @user_mapper.update user
    transaction = Transaction.new nil, nil, user, "deposit", amount
    @transaction_mapper.insert transaction
  end

end
