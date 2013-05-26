def enable_fk
  "PRAGMA foreign_keys = ON"
end

def get_db_path
  begin
    gem_dir = Gem::Specification.find_by_name('payfoe').gem_dir
    gem_dir += "/db/payfoe.db"
  rescue Gem::LoadError
    return "db/payfoe.db"
  end
end

def get_db_schema_path
  begin
    gem_dir = Gem::Specification.find_by_name('payfoe').gem_dir
    gem_dir += "/db/payfoe_schema.yaml"
  rescue Gem::LoadError
    return "db/payfoe_schema.db"
  end
end

