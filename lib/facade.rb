module PayFoe

  class Facade

    def initialize
      @user_mapper = PayFoe::UserMapper.new
      @transaction_mapper = PayFoe::TransactionMapper.new
    end
    
    def register(user)
      if !user.instance_of? PayFoe::User
        raise ArgumentError, 'user is invalid'
      end
      @user_mapper.insert(user)
    end

    def users
      @user_mapper.find_all
    end

    def user(id)
      @user_mapper.find id
    end

    def deposit(user, amount)
      user_validation user
      amount_validation amount

      user.balance += amount
      @user_mapper.update user
      transaction = PayFoe::Transaction.new nil, nil, user, "deposit", amount
      @transaction_mapper.insert transaction
      return amount
    end

    def withdraw(user, amount)
      user_validation user
      amount_validation amount

      user.balance -= amount
      if user.balance < 0
        withdrawn = amount + user.balance
        user.balance = 0
      else
        withdrawn = amount
      end
      @user_mapper.update user
      transaction = PayFoe::Transaction.new nil, user, nil, "withdrawal", amount
      @transaction_mapper.insert transaction
      return withdrawn
    end

    def pay(user_from, user_to, amount)
      user_validation(user_from)
      user_validation(user_to)
      amount_validation(amount)

      user_from.balance -= amount
      if user_from.balance < 0
        amount = amount + user_from.balance
        user_from.balance = 0
      end
      user_to.balance += amount
      if amount != 0
        @user_mapper.update user_from
        @user_mapper.update user_to
        transaction = PayFoe::Transaction.new nil, user_from, user_to, "payment", amount
        @transaction_mapper.insert transaction
      end
      return amount
    end

    def transactions
      @transaction_mapper.find_all
    end

    def transactions_of_user(id)
      @transaction_mapper.find_by_user id
    end

    private

    def user_validation(user)
      if (!user.kind_of? PayFoe::User and !user.kind_of? PayFoe::LazyObject) and user != nil
        raise ArgumentError, 'user is invalid'
      end
    end

    def amount_validation(amount)
      if !amount.kind_of? Numeric or amount <= 0
        raise ArgumentError, 'amount is invalid'
      end
    end

  end

end
