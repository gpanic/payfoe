class DataMapper

  def initialize(db_path = "db/payfoe.db")
    @db_path = db_path
    @identity_map = {}
  end

  def insert(entity)
    db = SQLite3::Database.open @db_path
    stm = db.prepare insert_stm
    do_insert entity, stm
    stm.execute
    stm.close
    id = db.last_insert_row_id
    db.close
    entity.id = id
    @identity_map[id] = entity
    return id
  end

  def find(id)
    if result = @identity_map[id]
      return result
    end
    db = SQLite3::Database.open @db_path
    rs = db.get_first_row find_stm, id
    db.close
    if rs
      return load rs
    else
      return nil
    end
  end

  def find_all
    find_many(find_all_stm)
  end

  def update(entity)
    db = SQLite3::Database.open @db_path
    stm = db.prepare update_stm
    do_update(entity, stm)
    stm.execute
    stm.close
    db.close
    return nil
  end

  def delete(id)
    db = SQLite3::Database.open @db_path
    db.execute delete_stm, id
    db.close
    return nil
  end

  def load(rs)
    id = rs[0]
    if result = @identity_map[id]
      return result
    end
    result = do_load id, rs
    @identity_map[id] = result
    return result
  end

  def load_all(rs)
    result = []
    rs.each do |row|
      result.push load row
    end
    return result
  end

  def find_many(stm, params = [])
    db = SQLite3::Database.open @db_path
    rs = db.execute stm, *params
    result = load_all rs
    db.close
    return result
  end

end
