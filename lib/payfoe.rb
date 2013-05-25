require_relative 'db_helper'
require_relative 'entities/user'
require_relative 'entities/transaction'
require_relative 'entities/lazy_object'
require_relative 'mappers/user_mapper'
require_relative 'mappers/transaction_mapper'
require_relative 'identity_map'
require_relative 'utility'

class PayFoe

  def initialize
    @user_mapper = UserMapper.new
    @transaction_mapper = TransactionMapper.new
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
    user_validation user
    amount_validation amount
    user.balance += amount
    @user_mapper.update user
    transaction = Transaction.new nil, nil, user, "deposit", amount
    @transaction_mapper.insert transaction
  end

  def withdraw(user, amount)
    user_validation user
    amount_validation amount
    user.balance -= amount
    user.balance = 0 if user.balance < 0
    @user_mapper.update user
    transaction = Transaction.new nil, user, nil, "withdrawal", amount
    @transaction_mapper.insert transaction
  end

  def user_validation(user)
    if !user.kind_of? User and user != nil
      raise ArgumentError, 'user is invalid'
    end
  end

  def amount_validation(amount)
    if !amount.kind_of? Numeric or amount <= 0
      raise ArgumentError, 'amount is invalid'
    end
  end

end
