module PayFoe

  class Transaction
    
    attr_accessor :id
    attr_writer :user_from
    attr_writer :user_to
    attr_accessor :type
    attr_accessor :amount

    def initialize(id, user_from, user_to, type, amount)
      @id = id
      @user_from = user_from
      @user_to = user_to
      @type = type
      @amount = amount
      @user_mapper = PayFoe::UserMapper.new
    end

    def user_from
      if @user_from.instance_of? PayFoe::LazyObject
        @user_from = @user_mapper.find @user_from.id
      else
        @user_from
      end
    end

    def user_to
      if @user_to.instance_of? PayFoe::LazyObject
        @user_to = @user_mapper.find @user_to.id
      else
        @user_to
      end
    end

  end

end
