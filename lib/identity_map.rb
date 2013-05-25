class IdentityMap

  @@user_map = {}

  def self.user_map
    @@user_map
  end

  def self.clean
    @@user_map = {}
  end

end
