require 'sqlite3'
require 'yaml'

module PayFoe

  class DBHelper

    attr_accessor :db_path
    attr_accessor :db_schema_path

    def initialize(db_path = get_db_path, db_schema_path = get_db_schema_path)
      @db_path = db_path
      @db_schema_path = db_schema_path
    end

    def init_db
      db_schema = YAML::load_file @db_schema_path
      db = SQLite3::Database.open @db_path
      db.execute enable_fk
      db_schema["tables"].each do | create_stm |
        db.execute create_stm
      end
      db.close if db
    end

  end

end
