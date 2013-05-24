require 'spec_helper'
require 'sqlite3'

describe UserMapper do

  before :all do
    # Prepare test environment
    @db_path = "db/test.db"
    @db_schema_path = "db/test_schema.yaml"
    @dbh = DBHelper.new(@db_path, @db_schema_path)

    # Create test db schema
    schema = File.open(@db_schema_path, "w")
    schema.write "tables:\n" +
                 "  - CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, email TEXT UNIQUE, name TEXT)\n"
    schema.close

    @dbh.init_db

    # Open test db
    @db = SQLite3::Database.open @db_path
  end

  after :all do
    # Close test db
    @db.close

    # Clean up
    File.delete @db_path
    File.delete @db_schema_path
  end

  subject { UserMapper.new @db_path }
  
  let(:test_user) { User.new(nil, "username", "email", "name") }

  before :each do
    @inserted_id = subject.insert(test_user)
  end

  after :each do
    @db.execute "DELETE FROM users"
  end

  describe '#insert' do

    it 'inserts the user into the db' do
      row = @db.get_first_row "SELECT username, email, name FROM users WHERE id = ?", @inserted_id
      row.sort.should eq [test_user.username, test_user.email, test_user.name].sort
    end

    it 'returns the created users id' do
      rs = @db.execute "SELECT * FROM users"
      expected_id = 0
      rs.each do | row |
        if row[1..-1] == [test_user.username, test_user.email, test_user.name]
          expected_id = row[0]
          break
        end
      end
      expected_id.should eq @inserted_id
    end

    it 'throws exception when username is not unique' do
      user = User.new(nil, "username", "email2", "name2")
      expect { subject.insert(user) }.to raise_error(SQLite3::ConstraintException)
    end

    it 'throws exception when email is not unique' do
      user = User.new(nil, "username2", "email", "name2")
      expect { subject.insert(user) }.to raise_error(SQLite3::ConstraintException)
    end

  end

  describe '#find' do

    it 'returns the correct user' do
      subject.find(@inserted_id).id.should eq @inserted_id
    end

    it 'returns nil when the user does not exist' do
      subject.find(@inserted_id - 1).should be_nil
    end

    it 'returns the correct values' do
      user = subject.find(@inserted_id)
      expected_user = test_user
      values = [user.id, user.username, user.email, user.name]
      expected_values = [@inserted_id, expected_user.username, expected_user.email, expected_user.name]
      values.should eq expected_values
    end

    it 'loads teh user only once' do
      user1 = subject.find(@inserted_id)
      user2 = subject.find(@inserted_id)
      user1.should eq user2
    end

  end

  describe '#update' do

    let(:updated_user) { User.new @inserted_id, "username2", "email2", "name2" }

    before(:each, before: true) do
      subject.update updated_user
    end

    it 'updates the correct user', before: true do
      row = @db.get_first_row "SELECT name FROM users WHERE id = ?", @inserted_id
      row[0].should eq updated_user.name
    end

    it 'updates only the correct user' do
      id = subject.insert User.new(nil, "/", "/", "/")
      row = @db.get_first_row "SELECT name FROM users WHERE id = ?", id
      row[0].should_not eq updated_user.name
    end

    it 'updates the user with the correct values', before: true do
      row = @db.get_first_row "SELECT username, email, name FROM users WHERE id = ?", @inserted_id
      row.sort.should eq [updated_user.username, updated_user.email, updated_user.name].sort
    end

  end

  describe '#delete' do

    it 'deletes the correct user' do
      subject.delete @inserted_id
      row = @db.execute "SELECT * FROM users WHERE id = ?", @inserted_id
      row.should be_empty
    end

    it 'deletes only the correct user' do
      subject.insert User.new(nil, "/", "/", "/")
      subject.delete @inserted_id
      rs = @db.execute "SELECT id FROM users"
      rs.size.should eq 1
    end

  end

  describe '#find_all' do

    it 'returns an array of all the users' do
      test_user.id = @inserted_id
      test_user2 = User.new(nil, "/", "/", "/")
      test_user2.id = subject.insert test_user2
      expected_array = [
        [test_user.id, test_user.username, test_user.email, test_user.name],
        [test_user2.id, test_user2.username, test_user2.email, test_user2.name]
      ]
      result = subject.find_all
      result_array = result.inject([]) { |final, user| final.push([user.id, user.username, user.email, user.name]) }
      result_array.should eq expected_array
    end

    it 'returns an empty array if there are no users' do
      @db.execute "DELETE FROM users"
      subject.find_all.should eq []
    end

  end

end
