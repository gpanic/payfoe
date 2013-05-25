require 'spec_helper'

describe PayFoe do

  let(:payfoe) { PayFoe.new }
  let(:user_mapper) { double "user_mapper" }
  let(:transaction_mapper) { double "transaction_mapper" }
  let(:test_user) { User.new(1, "username", "email", "name", 200) }
  let(:test_user2) { User.new(2, "username2", "email2", "name2", 300) }

  before :each do
    payfoe.instance_variable_set :@user_mapper, user_mapper
    payfoe.instance_variable_set :@transaction_mapper, transaction_mapper
    transaction_mapper.stub :insert
    user_mapper.stub :update
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
    end

    it 'doesn\'t raise an exception when the user is nil' do
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

    it 'adds to the balance of the user' do
      user_mapper.should_receive(:update) do |arg|
        arg.should eq test_user
        arg.balance.should eq 400.0
      end
      payfoe.deposit test_user, 200.0
    end

    it 'records the transaction' do
      expected = Transaction.new(nil, nil, test_user, "deposit", 200.0)
      transaction_expectation expected
      payfoe.deposit test_user, 200.0
    end

  end

  describe '#withdraw' do

    include_examples 'updates_user'
    include_examples 'input_validation', :withdraw


    it 'reduces the balance of the user' do
      user_mapper.should_receive(:update) do |arg|
        arg.should eq test_user
        arg.balance.should eq 50.0
      end
      payfoe.withdraw test_user, 150.0
    end

    it 'returns the withdrawn amount' do
      result = payfoe.withdraw test_user, 25.0
      result.should eq 25.0
    end

    it 'records the transaction' do
      expected = Transaction.new(nil, test_user, nil, "withdrawal", 200.0)
      transaction_expectation expected
      payfoe.withdraw test_user, 200.0
    end

    context 'when the amount is greater than the user\'s balance' do

      it 'doesn\'t lower the balance below 0' do
        user_mapper.should_receive(:update) do |arg|
          arg.should eq test_user
          arg.balance.should eq 0.0
        end
        payfoe.withdraw test_user, 400.0
      end

      it 'returns the available amount' do
        result = payfoe.withdraw test_user, 400.0
        result.should eq 200.0
      end

    end

  end

  describe '#pay' do

    it 'transfers the money' do
      transfer_expectation test_user.balance - 100.0, test_user2.balance + 100
      payfoe.pay test_user, test_user2, 100.0
    end


    context 'when the amount is greater than user_from\'s balance' do

      it 'should transfer the available amount' do
        transfer_expectation test_user.balance - test_user.balance, test_user2.balance + test_user.balance
        payfoe.pay test_user, test_user2, 300.0
      end

    end

    it 'records the transaction' do
      expected = Transaction.new(nil, test_user, test_user2, "payment", 200.0)
      transaction_expectation expected
      payfoe.pay test_user, test_user2, 200.0
    end

  end

  def transaction_expectation(transaction)
    transaction_mapper.should_receive(:insert) do |arg|
      arg.should be_an_instance_of Transaction
      arg.user_from.should eq transaction.user_from
      arg.user_to.should eq transaction.user_to
      arg.type.should eq transaction.type
      arg.amount.should eq transaction.amount
    end
  end

  def transfer_expectation(amount1, amount2)
    user_mapper.should_receive(:update).once do |arg|
      arg.should eq test_user
      arg.balance.should eq amount1
    end
    user_mapper.should_receive(:update).once do |arg|
      arg.should eq test_user2
      arg.balance.should eq amount2
    end
  end

end
