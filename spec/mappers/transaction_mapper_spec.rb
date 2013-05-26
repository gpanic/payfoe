require 'spec_helper'

describe PayFoe::TransactionMapper do

  it_behaves_like PayFoe::DataMapper
  include_context "DataMapperContext"

  def delete_all_stm
    "DELETE FROM transactions"
  end

  let(:mapper) { PayFoe::TransactionMapper.new @db_path }
  let(:identity_map) { double("tansactions_map") }
  let(:test_entity) { PayFoe::Transaction.new nil, nil, nil, "type", 100 }
  let(:test_entity2) { PayFoe::Transaction.new nil, nil, nil, "type2", 100 }
  let(:updated_entity) { PayFoe::Transaction.new @inserted_id, nil, nil, "type3", 200 }

  def entity_to_a(entity)
    array = []
    vars = entity.instance_variables - [:@user_mapper]
    vars.each do |var|
      method = var.to_s[1..-1]
      if var == :@user_from or var == :@user_to
        user = nil
        user = entity.instance_variable_get(var).id if entity.instance_variable_get(var)
        array.push user
      else
        array.push(entity.send(method.to_sym))
      end
    end
    return array
  end


  let(:user_mapper) { PayFoe::UserMapper.new @db_path }
  let(:test_user) { PayFoe::User.new nil, "u", "e", "n" }
  let(:test_user2) { PayFoe::User.new nil, "u2", "e2", "n2" }

  before :each, user: true do
    test_user.id = user_mapper.insert test_user
    test_user2.id = user_mapper.insert test_user2
    PayFoe::IdentityMap.clean
    test_entity.user_from = test_user
    test_entity.user_to = test_user2
    test_entity.id = mapper.insert test_entity
  end

  after :each, user: true do
    @db.execute "DELETE FROM transactions"
    @db.execute "DELETE FROM users"
  end

  after :each, clean: true do
    @db.execute "DELETE FROM transactions"
    @db.execute "DELETE FROM users"
    PayFoe::IdentityMap.clean
  end

  describe '#insert' do

    it 'inserts the user foreign keys correctly', user: true do
      row = @db.get_first_row mapper.find_stm, test_entity.id
      row[1, 2].should eq [test_user.id, test_user2.id]
    end
    
    it 'throws an exception when the user doesn\' exist', user: true do
      test_entity.user_from = PayFoe::User.new 99, nil, nil, nil
      test_entity.user_to = PayFoe::User.new 99, nil, nil, nil
      expect { mapper.insert test_entity }.to raise_error SQLite3::ConstraintException
    end

    it 'adds the user_from to the identity map', user: true do
      PayFoe::IdentityMap.users_map[test_entity.user_from.id].should eq test_entity.user_from
    end

    it 'adds the user_to to the identity map', user: true do
      PayFoe::IdentityMap.users_map[test_entity.user_to.id].should eq test_entity.user_to
    end

  end

  describe '#find' do

    it 'doesn\'t load the user_from', user: true do
      PayFoe::IdentityMap.clean
      transaction = mapper.find test_entity.id
      transaction.instance_variable_get(:@user_from).should be_an_instance_of(PayFoe::LazyObject)
    end

    it 'doesn\'t load the user_to', user: true do
      PayFoe::IdentityMap.clean
      transaction = mapper.find test_entity.id
      transaction.instance_variable_get(:@user_to).should be_an_instance_of(PayFoe::LazyObject)
    end

    it 'loads users from the identity map', clean: true do
      test_user.id = user_mapper.insert test_user
      test_entity.user_from = test_user
      test_entity.user_to = test_user
      test_entity.id = mapper.insert test_entity
      transaction = mapper.find(test_entity.id)
      actual = [transaction.user_from, transaction.user_to]
      expected = [PayFoe::IdentityMap.users_map[test_user.id], PayFoe::IdentityMap.users_map[test_user.id]]
      actual.should eq expected
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

  describe '#find_by_user' do

    it 'returns an array of all the users' do
      user_mapper.insert test_user
      test_entity.user_from = test_user
      test_entity2.user_to = test_user
      mapper.insert test_entity
      mapper.insert test_entity2
      PayFoe::IdentityMap.clean
      actual = mapper.find_by_user(test_user.id)
      actual.map! { |t| entity_to_a t }
      expected = @db.execute "SELECT * FROM transactions WHERE id = ? OR id = ?", test_entity.id, test_entity2.id
      actual.should eq expected
    end

  end

end
