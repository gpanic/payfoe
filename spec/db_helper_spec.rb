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

  let(:instance_vars) { [:@db_path, :@db_schema_path] }

  it 'has instance variables :@db_path, :@db_scheme'  do
    @dbh.instance_variables.should eq instance_vars
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
