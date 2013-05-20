require 'spec_helper'
require 'sqlite3'

describe UserMapper do

  before :all do
    # Prepare test environment
    @db_path = "db/test.db"
    @db_schema_path = "db/test_schema.yaml"

    # Create test db schema
    schema = File.open(@db_schema_path, "w")
    schema.write "tables:\n" +
                 "  - CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, email TEXT UNIQUE, name TEXT)\n"
    schema.close

    @dbh = DBHelper.new(@db_path, @db_schema_path)
    @dbh.init_db
  end

  after :all do
    File.delete @db_path
    File.delete @db_schema_path
  end
  
  describe '#insert' do
    
    let(:test_user) { User.new(nil, "username", "email", "name") }

    before :each do
      @user_mapper = UserMapper.new @db_path
      @inserted_id = @user_mapper.insert(test_user)
    end

    after :each do
      db = SQLite3::Database.open @db_path
      stm = db.prepare "DELETE FROM users WHERE id = ?"
      stm.bind_param 1, @inserted_id
      stm.execute
      stm.close
      db.close
    end

    it 'inserts the user into the db' do
      db = SQLite3::Database.open @db_path
      rs = db.execute "SELECT * FROM users"
      db.close
      inserted = false
      rs.each do | row |
        if row[1] == test_user.username and row[2] == test_user.email and row[3] == test_user.name
          inserted = true
          break
        end
      end
      inserted.should be_true
    end

    it 'returns the created users id' do
      db = SQLite3::Database.open @db_path
      rs = db.execute "SELECT * FROM users"
      db.close
      inserted_id = 0
      rs.each do | row |
        if row[1] == test_user.username and row[2] == test_user.email and row[3] == test_user.name
          inserted_id = row[0]
          break
        end
      end
      inserted_id.should eq @inserted_id
    end

    it 'throws exception when username is not unique' do
      user = User.new(nil, "username", "email2", "name2")
      expect { @user_mapper.insert(user) }.to raise_error(SQLite3::ConstraintException)
    end

    it 'throws exception when email is not unique' do
      user = User.new(nil, "username2", "email", "name2")
      expect { @user_mapper.insert(user) }.to raise_error(SQLite3::ConstraintException)
    end

  end

end
