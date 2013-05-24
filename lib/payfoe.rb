require 'db_helper'
require_relative 'entities/user'
require_relative 'mappers/user_mapper'

class PayFoe

  def initialize
    @user_mapper = UserMapper.new
  end
  
  def register(user)
    @user_mapper.insert(user)
  end

  def users
    @user_mapper.find_all
  end

end
