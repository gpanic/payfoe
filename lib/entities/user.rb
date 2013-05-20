class User

  attr_accessor :id
  attr_accessor :username
  attr_accessor :email
  attr_accessor :name

  def initialize(id, username, email, name)
    @id = id
    @username = username
    @email = email
    @name = name
  end

end
