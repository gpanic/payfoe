class User

  attr_accessor :id
  attr_accessor :username
  attr_accessor :email
  attr_accessor :name
  attr_accessor :balance

  def initialize(id, username, email, name, balance = 0)
    @id = id
    @username = username
    @email = email
    @name = name
    @balance = balance
  end

end
