require 'spec_helper'

describe PayFoe do

  let(:pf) { PayFoe.new }
  let(:user_mapper) { double "user_mapper" }
  let(:transaction_mapper) { double "transaction_mapper" }
  let(:test_user) { User.new(1, "username", "email", "name") }

  before :each do
    pf.instance_variable_set :@user_mapper, user_mapper
    pf.instance_variable_set :@transaction_mapper, transaction_mapper
  end

  describe '#register' do

    it 'registers the user' do
      user_mapper.should_receive(:insert).with(test_user)
      pf.register(test_user)
    end

    it 'returns the id of the registered user' do
      user_mapper.should_receive(:insert).with(test_user).and_return(1)
      pf.register(test_user).should eq 1
    end

    it 'raises an exception when the user is invalid' do
      expect { pf.register("asdf")}.to raise_error ArgumentError
    end

  end

  describe '#users' do

    it 'returns an array of all the registered users' do
      user_mapper.should_receive(:find_all).and_return([test_user, test_user])
      pf.users.should eq [test_user, test_user]
    end
  end

  describe '#deposit' do

    it 'updates the user' do
      transaction_mapper.stub :insert
      user_mapper.should_receive(:update).with(test_user)
      pf.deposit test_user, 200.0
    end

    it 'adds money to balance in the user object' do
      transaction_mapper.stub :insert
      user_mapper.should_receive(:update) do |arg|
        arg.should eq test_user
        arg.balance.should eq 200.0
      end
      pf.deposit test_user, 200.0
    end

    it 'records the transaction' do
      user_mapper.stub :update
      transaction_mapper.should_receive(:insert) do |arg|
        arg.should be_an_instance_of Transaction
        arg.user_from.should be_nil
        arg.user_to.should eq test_user
        arg.type.should eq "deposit"
        arg.amount.should eq 200.0
      end
      pf.deposit test_user, 200.0
    end

    it 'raises an exception when the amount is not Numeric' do
      expect { pf.deposit test_user, "invalid" }.to raise_error ArgumentError
    end

    it 'raises an exception when the amount is 0 or less' do
      expect { pf.deposit test_user, -1 }.to raise_error ArgumentError
    end

  end

end
