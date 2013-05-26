module PayFoe

  class CommandLine

    def user_headings
      ["Id", "Username", "Email", "Name", "Balance"]
    end

    def transactions_headings
      ["Id", "From id", "From username", "To id", "To username", "Type", "Amount"]
    end

    def initialize
      @facade = PayFoe::Facade.new
      @db_helper = PayFoe::DBHelper.new
    end

    def run
      if not File.exist? get_db_path
        @db_helper.init_db
      end

      case ARGV[0]

      when "help"
        print_usage
      when "-h"
        print_usage

      when "register"
        if ARGV.length == 4
          user = PayFoe::User.new nil, ARGV[1], ARGV[2], ARGV[3]
          begin
            id = @facade.register(user)
            puts "User with username #{ARGV[1]} registered with id: #{id}"
          rescue SQLite3::ConstraintException
            puts "Username or email is not unique"
          end
        else
          print_usage
        end

      when "users"
        users = @facade.users
        if not users.empty?
          table = Terminal::Table.new do |table|
            table.headings = *user_headings
            users.each do |user|
              table << [user.id, user.username, user.email, user.name, user.balance]
            end
          end
          puts table
        else 
          puts "No users found"
        end

      when "user"
        if ARGV.length == 2
          user = @facade.user ARGV[1]
          if user
            table = Terminal::Table.new do |table|
              table.headings = *user_headings 
              table << [user.id, user.username, user.email, user.name, user.balance]
            end
            puts table
          else
            puts "User does not exist"
          end
        else
          print_usage
        end

      when "deposit"
        if ARGV.length == 3
          user = @facade.user(ARGV[1])
          if user
            begin
              deposited = @facade.deposit(user, ARGV[2].to_f)
              puts "Deposited #{deposited}"
            rescue ArgumentError
              puts "Amount is invalid"
            end
          else
            puts "User does not exist"
          end
        else
          print_usage
        end

      when "withdraw"
        if ARGV.length == 3
          user = @facade.user(ARGV[1])
          if user
            begin
              withdrawn = @facade.withdraw(user, ARGV[2].to_f)
              puts "Withdrew #{withdrawn}"
            rescue ArgumentError
              puts "Amount is invalid"
            end
          else
            puts "User does not exist"
          end
        else
          print_usage
        end

      when "pay"
        if ARGV.length == 4
          user_from = @facade.user(ARGV[1])
          user_to = @facade.user(ARGV[2])
          if user_from and user_to
            begin
              amount = @facade.pay(user_from, user_to, ARGV[3].to_f)
              puts "Transaction completed, transfered #{amount}" if amount > 0
              puts "Balance is 0.0" if amount <= 0
            rescue ArgumentError
              puts "Amount is invalid"
            end
          else
            puts "One of the users does not exist"
          end
        else
          print_usage
        end

      when "transactions"
        if ARGV.length == 1
          transactions = @facade.transactions
          if not transactions.empty?
            table = Terminal::Table.new do |table|
              table.headings = *transactions_headings
              transactions.each do |transaction|
                user_from_id = "nil"
                user_from_username = "nil"
                if user_from = transaction.user_from
                  user_from_id = user_from.id
                  user_from_username = user_from.username
                end

                user_to_id = "nil"
                user_to_username = "nil"
                if user_to = transaction.user_to
                  user_to_id = user_to.id
                  user_to_username = user_to.username
                end
                table << [transaction.id, user_from_id, user_from_username, user_to_id, user_to_username, transaction.type, transaction.amount]
              end
            end
            puts table
          else
            puts "No transactions found"
          end
        elsif ARGV.length == 3
          if ARGV[1] == "user"
            transactions = @facade.transactions_of_user ARGV[2].to_i
            if not transactions.empty?
              table = Terminal::Table.new do |table|
                table.headings = *transactions_headings
                transactions.each do |transaction|
                  user_from_id = "nil"
                  user_from_username = "nil"
                  if user_from = transaction.user_from
                    user_from_id = user_from.id
                    user_from_username = user_from.username
                  end

                  user_to_id = "nil"
                  user_to_username = "nil"
                  if user_to = transaction.user_to
                    user_to_id = user_to.id
                    user_to_username = user_to.username
                  end
                  table << [transaction.id, user_from_id, user_from_username, user_to_id, user_to_username, transaction.type, transaction.amount]
                end
              end
              puts table
            else
              puts "No transactions for the specified user found"
            end
          else
            print_usage
          end
        else
          print_usage
        end

      when nil
        print_usage

      else
        print_usage

      end
    end

    def print_usage
      usage = "Usage:\n" +
        "payfoe register [username] [email] [name]     - registers the user\n" +
        "payfoe users                                  - displays all registered users\n" +
        "payfoe user [id]                              - displays the user with the specified id\n" +
        "payfoe deposit [id] [amount]                  - deposits amount to id\n" +
        "payfoe withdraw [id] [amount]                 - withdraws amount from id\n" +
        "payfoe pay [id1] [id2] [amount]               - transfers the amount from id1 to id2\n" +
        "payfoe transactions                           - displays all transactions\n" +
        "payfoe transactions user [id]                 - displays all transactions of the specified user\n"
      puts usage
    end

  end

end
