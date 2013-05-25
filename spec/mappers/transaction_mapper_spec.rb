require 'spec_helper'

describe TransactionMapper do

  it_behaves_like DataMapper
  include_context "DataMapperContext"

  def delete_all_stm
    "DELETE FROM transactions"
  end

  let(:mapper) { TransactionMapper.new @db_path }
  let(:test_entity) { Transaction.new nil, nil, nil, "type", 100 }
  let(:test_entity2) { Transaction.new nil, nil, nil, "type2", 100 }
  let(:updated_entity) { Transaction.new @inserted_id, nil, nil, "type3", 200 }

  def entity_to_a(entity)
    array = []
    vars = entity.instance_variables - [:@user_mapper]
    vars.each do |var|
      method = var.to_s[1..-1]
      array.push(entity.send(method.to_sym))
    end
    return array
  end


  let(:user_mapper) { UserMapper.new @db_path }
  let(:test_user) { User.new nil, "u", "e", "n" }
  let(:test_user2) { User.new nil, "u2", "e2", "n2" }

  before :each, user: true do
    test_user.id = user_mapper.insert test_user
    test_user2.id = user_mapper.insert test_user2
    test_entity.user_from = test_user
    test_entity.user_to = test_user2
    test_entity.id = mapper.insert test_entity
  end

  after :each, user: true do
    @db.execute "DELETE FROM transactions"
    @db.execute "DELETE FROM users"
  end

  describe '#insert' do

    it 'inserts the user foreign keys correctly', user: true do
      row = @db.get_first_row mapper.find_stm, test_entity.id
      row[1, 2].should eq [test_user.id, test_user2.id]
    end
    
    it 'throws an exception when the user doesn\' exist', user: true do
      test_entity.user_from = User.new 99, nil, nil, nil
      test_entity.user_to = User.new 99, nil, nil, nil
      expect { mapper.insert test_entity }.to raise_error SQLite3::ConstraintException
    end

  end

  describe '#find' do

    it 'doesn\'t load the user_from', user: true do
      IdentityMap.clean
      transaction = mapper.find test_entity.id
      transaction.instance_variable_get(:@user_from).should be_an_instance_of(LazyObject)
    end

    it 'doesn\'t load the user_to', user: true do
      IdentityMap.clean
      transaction = mapper.find test_entity.id
      transaction.instance_variable_get(:@user_to).should be_an_instance_of(LazyObject)
    end

  end

  describe '#update' do

    it 'updates the foreign keys correctly', user: true do
      test_entity.user_from = test_user2
      test_entity.user_to = test_user
      mapper.update test_entity

      row = @db.get_first_row mapper.find_stm, test_entity.id
      row[1, 2].should eq [test_user2.id, test_user.id]
    end

  end

end
