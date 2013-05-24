require 'spec_helper'

describe DBHelper do

  before :all do
    # Prepare test environment
    @db_path = "db/test.db"
    @db_schema_path = "db/test_schema.yaml"

    # Create test db schema
    schema = File.open(@db_schema_path, "w")
    schema.write "tables:\n" +
                 "  - CREATE TABLE test_table1 (id INTEGER PRIMARY KEY, column1 TEXT, column2 INTEGER)\n" +
                 "  - CREATE TABLE test_table2 (id INTEGER PRIMARY KEY, column1 TEXT)"
    schema.close

    @dbh = DBHelper.new(@db_path, @db_schema_path)
    @dbh.init_db
  end

  after :all do
    File.delete @db_path
    File.delete @db_schema_path
  end

  describe 'has a property db_path which' do
    
    it 'returns the path to the db' do
      @dbh.db_path.should eq @db_path
    end

    it 'sets the path to the db correctly' do
      @dbh.db_path = "new path"
      @dbh.db_path.should eq "new path"
    end

  end

  describe 'has a property db_schema_path which' do
    
    it 'returns the path to the db schema' do
      @dbh.db_schema_path.should eq @db_schema_path
    end

    it 'sets the path to the db_schema correctly' do
      @dbh.db_schema_path = "new path"
      @dbh.db_schema_path.should eq "new path"
    end

  end

  describe '#init_db' do

    it 'creates the db file' do
      File.exists?(@db_path).should be_true
    end

    it 'creates the right tables' do
      db = SQLite3::Database.open @db_path
      rs = db.execute "SELECT tbl_name FROM sqlite_master WHERE type='table'"
      rs = rs.map { | row | row[0] }
      rs.should include("test_table1", "test_table2")
    end

    it 'creates the right columns' do
      db = SQLite3::Database.open @db_path
      rs = db.execute "PRAGMA table_info(test_table1)"
      rs = rs.map { | row | row[1] }
      rs.sort.should eq ["id", "column1", "column2"].sort
    end

  end

end
