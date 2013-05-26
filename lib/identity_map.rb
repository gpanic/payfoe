module PayFoe

  class IdentityMap

    @@users_map = {}
    @@transactions_map = {}

    def self.users_map
      @@users_map
    end

    def self.transactions_map
      @@transactions_map
    end

    def self.clean
      @@users_map = {}
      @@transactions_map = {}
    end

  end

end
