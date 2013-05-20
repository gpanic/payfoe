require 'db_helper'
require_relative 'entities/user'
require_relative 'mappers/user_mapper'

class PayFoe
  
  def user_mapper=(user_mapper)
    @user_mapper = user_mapper
  end

  def register(user)
    @user_mapper.insert(user)
  end

end
