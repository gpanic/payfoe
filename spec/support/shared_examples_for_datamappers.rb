shared_context "DataMapperContext" do

  before :all do
    # Prepare test environment
    @db_path = "db/test.db"
    @db_schema_path = "db/test_schema.yaml"
    @dbh = DBHelper.new(@db_path, @db_schema_path)

    # Create test db schema
    schema = File.open(@db_schema_path, "w")
    schema.write "tables:\n" +
                 "  - CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, email TEXT UNIQUE, name TEXT, balance INTEGER)\n"
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

  after :each do
    @db.execute delete_all_stm
  end

  before :each do
    @inserted_id = mapper.insert(test_entity)
  end

end

shared_examples DataMapper do

  describe '#insert' do

    it 'inserts the entity into the db' do
      row = @db.get_first_row mapper.find_stm, @inserted_id
      row.should eq entity_to_a(test_entity)
    end

    it 'returns the created entity\'s id' do
      rs = @db.execute mapper.find_all_stm
      id = 0
      rs.each do | row |
        if row[1..-1] == entity_to_a(test_entity)[1..-1]
          id = row[0]
          break
        end
      end
      @inserted_id.should eq id
    end

  end

  describe '#find' do

    it 'returns the correct entity' do
      entity = mapper.find(@inserted_id)
      entity.id.should eq @inserted_id
    end

    it 'returns nil when the entity does not exist' do
      entity = mapper.find(@inserted_id - 1)
      entity.should be_nil
    end

    it 'returns the correct values' do
      entity = mapper.find(@inserted_id)
      test_entity.id = @inserted_id
      entity_to_a(entity).should eq entity_to_a(test_entity)
    end

    it 'loads the entity only once' do
      entity = mapper.find(@inserted_id)
      entity2 = mapper.find(@inserted_id)
      entity.should eq entity2
    end

  end

  describe '#update' do

    before(:each, before: true) do
      mapper.update updated_entity
    end

    it 'updates the correct entity', before: true do
      row = @db.get_first_row mapper.find_stm, @inserted_id
      row[1].should eq entity_to_a(updated_entity)[1]
    end

    it 'updates only the correct entity' do
      id = mapper.insert test_entity2
      row = @db.get_first_row mapper.find_stm, id
      row[1].should_not eq entity_to_a(updated_entity)[1]
    end

    it 'updates the entity with the correct values', before: true do
      row = @db.get_first_row mapper.find_stm, @inserted_id
      row.should eq entity_to_a(updated_entity)
    end

  end

  describe '#delete' do

    it 'deletes the correct entity' do
      mapper.delete @inserted_id
      row = @db.execute mapper.find_stm, @inserted_id
      row.should be_empty
    end

    it 'deletes only the correct entity' do
      mapper.insert test_entity2
      mapper.delete @inserted_id
      rs = @db.execute mapper.find_all_stm
      rs.size.should eq 1
    end

  end

  describe '#find_all' do

    it 'returns an array of all the entities' do
      test_entity.id = @inserted_id
      id = mapper.insert test_entity2
      test_entity2.id = id
      expected_array = [entity_to_a(test_entity), entity_to_a(test_entity2)]
      result = mapper.find_all
      result_array = result.inject([]) { |result, entity| result.push(entity_to_a(entity)) }
      result_array.should eq expected_array
    end

    it 'returns an empty array if there are no entities' do
      @db.execute delete_all_stm
      mapper.find_all.should eq []
    end

  end

end
