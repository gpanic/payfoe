require 'spec_helper'

describe UserMapper do

  it_behaves_like DataMapper
  include_context "DataMapperContext"

  def delete_all_stm
    "DELETE FROM users"
  end

  let(:mapper) { UserMapper.new @db_path }
  let(:test_entity) { User.new(nil, "username", "email", "name") }
  let(:test_entity2) { User.new(nil, "username2", "email2", "name2") }
  let(:updated_entity) { User.new @inserted_id, "username3", "email3", "name3", 200 }

  describe '#insert' do

    it 'throws an exception when username is not unique' do
      user = User.new(nil, "username", "email2", "name2")
      expect { mapper.insert(user) }.to raise_error(SQLite3::ConstraintException)
    end

    it 'throws an exception when email is not unique' do
      user = User.new(nil, "username2", "email", "name2")
      expect { mapper.insert(user) }.to raise_error(SQLite3::ConstraintException)
    end

  end

  def entity_to_a(entity)
    array = []
    vars = entity.instance_variables
    vars.each do |var|
      method = var.to_s[1..-1]
      array.push(entity.send(method.to_sym))
    end
    return array
  end

end
