require 'spec_helper'

describe PayFoe do

  let(:payfoe) { PayFoe.new }
  let(:user_mapper) { double "user_mapper" }
  let(:transaction_mapper) { double "transaction_mapper" }
  let(:test_user) { User.new(1, "username", "email", "name", 200) }

  before :each do
    payfoe.instance_variable_set :@user_mapper, user_mapper
    payfoe.instance_variable_set :@transaction_mapper, transaction_mapper
  end

  shared_examples 'updates_user' do

    it 'updates the user' do
      transaction_mapper.stub :insert
      user_mapper.should_receive(:update).with(test_user)
      payfoe.deposit test_user, 200.0
    end

  end

  shared_examples 'input_validation' do |method|

    it 'raises an exception when the amount is not Numeric' do
      expect { payfoe.send method, test_user, "invalid" }.to raise_error ArgumentError
    end

    it 'raises an exception when the amount is 0 or less' do
      expect { payfoe.send method, test_user, -1 }.to raise_error ArgumentError
    end

    it 'raises an exception when the user is not a user object' do
      expect { payfoe.send method, "asdf", 200 }.to raise_error ArgumentError
      expect { payfoe.send method, nil, 200 }.to_not raise_error ArgumentError
    end

  end

  describe '#register' do

    it 'registers the user' do
      user_mapper.should_receive(:insert).with(test_user)
      payfoe.register(test_user)
    end

    it 'returns the id of the registered user' do
      user_mapper.should_receive(:insert).with(test_user).and_return(1)
      payfoe.register(test_user).should eq 1
    end

    it 'raises an exception when the user is invalid' do
      expect { payfoe.register("asdf")}.to raise_error ArgumentError
    end

  end

  describe '#users' do

    it 'returns an array of all the registered users' do
      user_mapper.should_receive(:find_all).and_return([test_user, test_user])
      payfoe.users.should eq [test_user, test_user]
    end

  end

  describe '#deposit' do

    include_examples 'updates_user'
    include_examples 'input_validation', :deposit

    it 'adds money to the balance of the user' do
      transaction_mapper.stub :insert
      user_mapper.should_receive(:update) do |arg|
        arg.should eq test_user
        arg.balance.should eq 400.0
      end
      payfoe.deposit test_user, 200.0
    end

    it 'records the transaction' do
      user_mapper.stub :update
      transaction_mapper.should_receive(:insert) do |arg|
        transaction_should_have arg, nil, test_user, "deposit"
      end
      payfoe.deposit test_user, 200.0
    end

  end

  describe '#withdraw' do

    include_examples 'updates_user'
    include_examples 'input_validation', :withdraw

    it 'removes money from the balance of the user' do
      transaction_mapper.stub :insert
      user_mapper.should_receive(:update) do |arg|
        arg.should eq test_user
        arg.balance.should eq 50.0
      end
      payfoe.withdraw test_user, 150.0
    end

    it 'records the transaction' do
      user_mapper.stub :update
      transaction_mapper.should_receive(:insert) do |arg|
        transaction_should_have arg, test_user, nil, "withdrawal"
      end
      payfoe.withdraw test_user, 150.0
    end

    it 'doesn\'t lower the balance under 0' do
      transaction_mapper.stub :insert
      user_mapper.should_receive(:update) do |arg|
        arg.should eq test_user
        arg.balance.should eq 0.0
      end
      payfoe.withdraw test_user, 400.0
    end

  end

  def transaction_should_have(arg, user_from, user_to, type)
    arg.should be_an_instance_of Transaction
    arg.user_from.should eq user_from
    arg.user_to.should eq user_to
    arg.type.should eq type
  end

end
