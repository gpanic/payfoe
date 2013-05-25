class Transaction
  
  attr_accessor :id
  attr_accessor :user_from
  attr_accessor :user_to
  attr_accessor :type
  attr_accessor :amount

  def initialize(id, user_from, user_to, type, amount)
    @id = id
    @user_from = user_from
    @user_to = user_to
    @type = type
    @amount = amount
  end

end
